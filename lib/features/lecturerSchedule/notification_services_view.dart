import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  // Show custom notification based on appointment status change
  static Future<void> showStatusChangeNotification(
      String studentId, String status) async {
    try {
      print(
          "Preparing to show notification for student: $studentId, status: $status");

      // Fetch the student's name or other information (if necessary)
      DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('appointments') // Assuming appointments collection exists
          .doc(studentId)
          .get();

      String studentName =
          (studentSnapshot.exists && studentSnapshot.data() != null)
              ? (studentSnapshot.data() as Map<String, dynamic>)['username'] ??
                  'Student'
              : 'Student'; // Default to 'Student' if name is unavailable

      await flutterLocalNotificationsPlugin.show(
        0, // Notification ID (you can generate a unique one)
        'Appointment Status Updated',
        'The appointment with $studentName has been $status.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'appointment_updates', // Channel ID
            'Appointment Updates', // Channel Name
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker',
          ),
        ),
      );

      print("Notification sent for student: $studentName, status: $status");
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  // Initialize the notifications
  static Future<void> initialize(
      FlutterLocalNotificationsPlugin pluginInstance) async {
    try {
      flutterLocalNotificationsPlugin = pluginInstance;

      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);

      // Await initialization of the notifications plugin
      final bool? initialized =
          await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
          print("Notification clicked with payload: ${response.payload}");
        },
      );

      if (initialized != null && initialized) {
        print("FlutterLocalNotificationsPlugin initialized successfully.");
      } else {
        print("Failed to initialize FlutterLocalNotificationsPlugin.");
      }
    } catch (e) {
      print("Error initializing NotificationService: $e");
    }
  }
}
