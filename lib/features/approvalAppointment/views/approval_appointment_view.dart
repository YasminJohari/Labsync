import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labsync/features/lecturerSchedule/notification_services_view.dart';
import 'package:labsync/models/appointment_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

class ApprovalAppointmentView extends StatelessWidget {
  final String lecturerId;

  const ApprovalAppointmentView({
    super.key,
    required this.lecturerId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ApprovalAppointmentViewModel(lecturerId),
      child: DefaultTabController(
        length: 3, // Number of tabs
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Approve Appointments'),
            backgroundColor: const Color.fromARGB(255, 99, 29, 59),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Pending'),
                Tab(text: 'Approved'),
                Tab(text: 'Rejected'),
              ],
            ),
          ),
          body: Consumer<ApprovalAppointmentViewModel>(
            builder: (context, viewModel, _) {
              return Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildAppointmentList(
                            viewModel.pendingAppointments, "Pending", context),
                        _buildAppointmentList(viewModel.approvedAppointments,
                            "Approved", context),
                        _buildAppointmentList(viewModel.rejectedAppointments,
                            "Rejected", context),
                      ],
                    ),
                  ),
                  if (viewModel.isLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentList(
      List<Appointment> appointments, String status, BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Text(
          'No $status appointments available',
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(
              'Student Name: ${appointment.studentId}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Time: ${TimeOfDay.fromDateTime(appointment.time).format(context)}\n'
              'Date: ${appointment.date.toLocal().toString().split(' ')[0]}\n'
              'Status: ${appointment.status}',
              style: const TextStyle(fontSize: 14),
            ),
            trailing: status == "Pending"
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _showConfirmationDialog(
                          context: context,
                          action: 'approve',
                          onConfirm: () => context
                              .read<ApprovalAppointmentViewModel>()
                              .updateAppointmentStatus(
                                appointment.id,
                                'Approved',
                              ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _showConfirmationDialog(
                          context: context,
                          action: 'reject',
                          onConfirm: () => context
                              .read<ApprovalAppointmentViewModel>()
                              .updateAppointmentStatus(
                                appointment.id,
                                'Rejected',
                              ),
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }

  Future<void> _showConfirmationDialog({
    required BuildContext context,
    required String action,
    required Function onConfirm,
  }) async {
    final bool confirmed = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm $action'),
            content: Text('Are you sure you want to $action this appointment?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) onConfirm();
  }
}

class ApprovalAppointmentViewModel extends ChangeNotifier {
  final String lecturerId;

  ApprovalAppointmentViewModel(this.lecturerId) {
    _appointmentsStream = FirebaseFirestore.instance
        .collection('appointments')
        .where('lecturerId', isEqualTo: lecturerId)
        .snapshots();
    _fetchAppointments();
  }

  late Stream<QuerySnapshot> _appointmentsStream;
  List<Appointment> pendingAppointments = [];
  List<Appointment> approvedAppointments = [];
  List<Appointment> rejectedAppointments = [];
  bool isLoading = true;

  void _fetchAppointments() {
    _appointmentsStream.listen((querySnapshot) {
      pendingAppointments.clear();
      approvedAppointments.clear();
      rejectedAppointments.clear();
      isLoading = true;
      notifyListeners();

      for (var doc in querySnapshot.docs) {
        final appointment = Appointment.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );

        if (appointment.userRole == "Student") {
          _ensureFCMToken(appointment.studentId, doc.id);

          switch (appointment.status) {
            case "Pending":
              pendingAppointments.add(appointment);
              break;
            case "Approved":
              approvedAppointments.add(appointment);
              break;
            case "Rejected":
              rejectedAppointments.add(appointment);
              break;
          }
        }
      }

      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
      });

      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .get();
      if (snapshot.exists) {
        String studentId = snapshot.data()?['studentId'];
        await NotificationService.showStatusChangeNotification(
            studentId, status);
      }
    } catch (e) {
      print("Error updating appointment status: $e");
    }
  }

  Future<void> _ensureFCMToken(String studentId, String appointmentId) async {
    final studentDoc = await FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .get();
    if (!studentDoc.exists || studentDoc.data()?['fcmToken'] == null) {
      await addStudentWithFCMToken(studentId, appointmentId);
    }
  }

  Future<void> addStudentWithFCMToken(
      String studentId, String appointmentId) async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointmentId)
            .set(
          {
            'fcmToken': fcmToken,
          },
          SetOptions(merge: true),
        );
      }
    } catch (e) {
      print("Error adding FCM token to appointment: $e");
    }
  }
}