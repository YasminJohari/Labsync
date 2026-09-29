import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:labsync/features/activityHistory/activity_history_viewmodel.dart';
import 'package:map_mvvm/view/view.dart';

class ActivityHistoryView extends StatelessWidget {
  final String lecturerId;

  const ActivityHistoryView({super.key, required this.lecturerId});

  @override
  Widget build(BuildContext context) {
    return ViewWrapper<ActivityHistoryViewModel>(
      showProgressIndicator: true, // Show progress while loading data
      builder: (context, viewModel) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Activity History'),
              backgroundColor: const Color.fromARGB(255, 99, 29, 59),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.people), text: 'Appointment History'),
                  Tab(icon: Icon(Icons.history), text: 'Work Progress History'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // Appointment History Tab
                FutureBuilder<void>(
                  future: viewModel.fetchAppointments(lecturerId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (viewModel.appointments.isEmpty) {
                      return const Center(
                        child: Text('No appointments found.',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      );
                    } else {
                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: viewModel.appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = viewModel.appointments[index];
                          return Card(
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.calendar_today,
                                  color: Colors.purple),
                              title: Text(
                                appointment.reason,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('dd MMM yyyy, hh:mm a')
                                        .format(appointment.time),
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  Text(
                                    'With student: ${appointment.studentId}', // Display student ID
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),

                // Work Progress History Tab
                FutureBuilder<void>(
                  future: viewModel.fetchWorkProgress(lecturerId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (viewModel.workProgress.isEmpty) {
                      return const Center(
                          child: Text('No work progress found.',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)));
                    } else {
                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: viewModel.workProgress.length,
                        itemBuilder: (context, index) {
                          final progress = viewModel.workProgress[index];
                          return Card(
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.assignment,
                                  color: Colors.teal),
                              title: Text(
                                progress.progressTitle,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Description: ${progress.progressDescription}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Student ID: ${progress.studentId}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Submission Date: ${DateFormat('dd MMM yyyy').format(progress.submissionDate)}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Comments: ${progress.comments.join(", ")}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
