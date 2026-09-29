import 'package:flutter/material.dart';
import 'package:map_mvvm/view/view.dart';
import 'package:provider/provider.dart';
import 'student_notification_viewmodel.dart';

class StudentNotificationView extends StatelessWidget {
  final String studentId;

  const StudentNotificationView({Key? key, required this.studentId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewWrapper<StudentNotificationViewModel>(
      builder: (context, viewmodel) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewmodel.fetchNotifications(studentId);
        });
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            backgroundColor: const Color.fromARGB(255, 99, 29, 59),
          ),
          body: Consumer<StudentNotificationViewModel>(
            builder: (context, viewModel, child) {
              // Check if the Viewmodel is busy (loading)
              if (viewModel.busy) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Check if there are no notifications
              if (viewModel.notifications.isEmpty) {
                return const Center(
                  child: Text(
                    'No notifications available.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: viewModel.notifications.length,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemBuilder: (context, index) {
                  final appointment = viewModel.notifications[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.pink.shade100,
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.pink,
                        ),
                      ),
                      title: const Text(
                        "Upcoming Appointment!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 99, 29, 59),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reason: ${appointment.reason}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Date: ${appointment.date.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Time: ${appointment.time.toLocal().toString().split(' ')[1].substring(0, 5)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: appointment.status == 'Approved'
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              appointment.status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: appointment.status == 'Approved'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                'Appointment Details',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 99, 29, 59),
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reason: ${appointment.reason}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Date: ${appointment.date.toLocal().toString().split(' ')[0]}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Time: ${appointment.time.toLocal().toString().split(' ')[1].substring(0, 5)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Status: ${appointment.status}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: appointment.status == 'Approved'
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Additional Notes: ${appointment.additionalNotes}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text(
                                    'Close',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 99, 29, 59),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
