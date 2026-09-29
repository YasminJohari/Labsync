import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:labsync/configs/services_locators.dart';
import 'package:labsync/features/login/views/login_view.dart';
import 'package:labsync/features/appointmentFormPage/views/appointment_form_view.dart';
import 'package:labsync/features/updateSchedule/viewmodels/update_schedule_viewmodel.dart';
import 'package:labsync/features/updateSchedule/views/update_schedule_view.dart';
import 'package:labsync/features/attendance/views/update_att_view.dart';
import 'package:labsync/features/lecturerSchedule/notification_services_view.dart';
import 'package:labsync/services/lecturerSchedule/lecturer_schedule_abstract.dart';
import 'package:labsync/services/lecturerSchedule/lecturer_schedule_implementation.dart';
import 'package:provider/provider.dart'; // Import provider for state management
import 'package:labsync/features/filterAppointment/views/filter_appointment_screen.dart';
import 'package:labsync/features/filterAppointment/viewmodels/filter_appointment_viewmodel.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final serviceLocator = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();

  // Initialize notifications
  final androidInitializationSettings =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  final initializationSettings =
      InitializationSettings(android: androidInitializationSettings);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Initialize NotificationService with the same instance
  await NotificationService.initialize(flutterLocalNotificationsPlugin);

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request notification permissions (iOS)
  messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Check the authorization status
  NotificationSettings settings = await messaging.getNotificationSettings();

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else {
    print('User denied permission');
  }

  // Fetch and store FCM token for the current student
  FirebaseMessaging.instance.getToken().then((String? token) async {
    if (token != null) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String studentId = user.uid;
        try {
          // Update the FCM token in the appointments collection after student login
          DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
              .collection('appointments')
              .doc(studentId) // Store the token in the appointments collection
              .get();

          if (studentSnapshot.exists) {
            // If the document exists, update the token
            await FirebaseFirestore.instance
                .collection('appointments')
                .doc(studentId)
                .update({'fcmToken': token});
            print("FCM Token updated for student ID: $studentId");
          } else {
            // If the document doesn't exist, create it
            await FirebaseFirestore.instance
                .collection('appointments')
                .doc(studentId)
                .set({'fcmToken': token});
            print("New FCM Token added for student ID: $studentId");
          }
        } catch (e) {
          print("Error updating Firestore: $e");
        }
      }
    }
  });

  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // Initialize service locator
  initializeServiceLocator();

  runApp(const MyApp());
}

void setupNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'appointment_updates', // Channel ID
    'Appointment Updates', // Channel Name
    description: 'Notifications for appointment updates',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

// Send push notification from backend when status changes
Future<void> sendPushNotification(String studentId, String message) async {
  // Retrieve the FCM token from Firestore using the studentId
  DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
      .collection('appointments')
      .doc(studentId)
      .get();

  String? fcmToken = studentSnapshot['fcmToken'];

  if (fcmToken != null) {
    final Map<String, dynamic> messagePayload = {
      'to': fcmToken,
      'notification': {
        'title': 'Appointment Status Update',
        'body': message,
      },
    };

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Authorization':
            'key=Firebase Server Key', // Use Firebase Server Key
        'Content-Type': 'application/json',
      },
      body: json.encode(messagePayload),
    );
  }
}

void listenToAppointmentChanges() {
  FirebaseFirestore.instance
      .collection('appointments')
      .where('studentId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
      .snapshots()
      .listen((snapshot) {
    for (var doc in snapshot.docs) {
      var appointmentStatus = doc['status'];
      if (appointmentStatus == 'approved' || appointmentStatus == 'rejected') {
        // Show local notification when status changes
        showLocalNotification(appointmentStatus);
      }
    }
  });
}

void showLocalNotification(String status) async {
  // Customize the notification based on the appointment status
  String title = 'Appointment Status Update';
  String body = 'Your appointment has been $status.';

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'appointment_updates', // Channel ID
    'Appointment Updates', // Channel Name
    importance: Importance.high,
    priority: Priority.high, // Ensure the notification is high priority
  );

  const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    title, // Notification Title
    body, // Notification Body
    platformDetails, // Platform-specific details
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide the ViewModel using the service locator
        ChangeNotifierProvider(
          create: (_) => serviceLocator<LecturerScheduleViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => AppointmentViewModel(),
        ),
        Provider<LecturerScheduleServiceAbstract>(
          create: (_) => LecturerScheduleServiceImplementation(
              serviceLocator<FirebaseFirestore>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginView(),
          '/update_schedule': (context) {
            final lecturerId =
                ModalRoute.of(context)!.settings.arguments as String;
            return LecturerScheduleUpdateView(
              lecturerId: lecturerId,
            );
          },
          '/appointment_form': (context) {
            final arguments = ModalRoute.of(context)?.settings.arguments
                    as Map<String, String>? ??
                {};
            final userRole = arguments['userRole'] ?? 'Student';

            return AppointmentFormView(
              selectedDate: DateTime.now(),
              selectedTime: DateTime.now(),
              username: arguments['username']!,
              studentId: arguments['studentId']!,
              lecturerId: arguments['lecturerId']!,
              userRole: userRole,
              id: '',
              status: '',
            );
          },
          '/student_dashboard': (context) {
            final arguments = ModalRoute.of(context)!.settings.arguments
                as Map<String, String>;
            return StudentDashboardView(
              username: arguments['username']!,
              lecturerId: arguments['lecturerId']!,
            );
          },
          '/appointments': (context) => AppointmentScreen(),
        },
      ),
    );
  }
}
