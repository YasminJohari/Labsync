import 'package:flutter/material.dart';
import 'package:labsync/features/approvalAppointment/views/approval_appointment_view.dart';
import 'package:labsync/features/notificationRequest/notification_request_viewmodel.dart';
import 'package:map_mvvm/view/view.dart';

class NotificationView extends StatelessWidget {
  final String lecturerId;

  const NotificationView({super.key, required this.lecturerId});

  @override
  Widget build(BuildContext context) {
    return ViewWrapper<NotificationViewModel>(
      builder: (context, viewmodel) {
        // Ensure the ViewModel fetches notifications only once during initialization
        if (!viewmodel.initialized) {
          viewmodel.fetchNotifications(lecturerId);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Appointment Requests'),
            backgroundColor: const Color.fromARGB(255, 99, 29, 59),
          ),
          body: Column(
            children: [
              // Toggle Buttons for All Requests and Recommendations
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => viewmodel.fetchNotifications(lecturerId),
                    child: const Text('View All Requests'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () =>
                        viewmodel.fetchRecommendedAppointments(lecturerId),
                    child: const Text('View Recommendations'),
                  ),
                ],
              ),
              // Display Loading Indicator or List of Appointments
              viewmodel.busy
                  ? const Center(child: CircularProgressIndicator())
                  : viewmodel.appointmentRequests.isEmpty
                      ? const Center(
                          child: Text('No new appointment requests.'),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: viewmodel.appointmentRequests.length,
                            itemBuilder: (context, index) {
                              final appointment = viewmodel.appointmentRequests[index];
                              return Card(
                                child: ListTile(
                                  title: Text(
                                    'Appointment with ${appointment.username}',
                                  ),
                                  subtitle: Text(
                                    '${appointment.date.toLocal()} at ${appointment.time}',
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    // Navigate to the ApprovalAppointmentView when an appointment is tapped
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ApprovalAppointmentView(
                                          lecturerId: lecturerId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ],
          ),
        );
      },
      progressBuilder: (_, __) => const Center(child: CircularProgressIndicator()),
    );
  }
}