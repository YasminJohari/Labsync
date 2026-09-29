import 'package:flutter/material.dart';
import 'package:labsync/configs/services_locators.dart';
import 'package:labsync/features/labPresence/viewmodel/lab_presence_viewmodel.dart';
import 'package:labsync/features/labHistory/view/lab_usage_history_view.dart'; // Import LabUsageHistoryView

class LabAttendanceView extends StatelessWidget {
  final String lecturerId;

  const LabAttendanceView({super.key, required this.lecturerId});

  @override
  Widget build(BuildContext context) {
    // Retrieve ViewModel using Service Locator
    final labPresenceViewModel = serviceLocator<LabPresenceViewModel>(
      param1: lecturerId,
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lab Attendance'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Current Presence'),
              Tab(icon: Icon(Icons.history), text: 'Usage History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Current lab presence view
            FutureBuilder(
              future: labPresenceViewModel.fetchStudentsInLab(),
              builder: (context, snapshot) {
                // Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error State
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error.toString()}'),
                  );
                }

                // Empty State
                if (labPresenceViewModel.students.isEmpty) {
                  return const Center(child: Text('No students in the lab.'));
                }

                // Loaded State
                return ListView.builder(
                  itemCount: labPresenceViewModel.students.length,
                  itemBuilder: (context, index) {
                    final student = labPresenceViewModel.students[index];
                    return ListTile(
                      leading: Icon(
                        Icons.person,
                        color: student['attendanceStatus'] ==
                                'You are inside the lab building.'
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text(student['name']),
                      subtitle:
                          Text('Classroom: ${student['currentClassroom']}'),
                      trailing: Text(
                        student['attendanceStatus'] ==
                                'You are inside the lab building.'
                            ? 'Present in lab'
                            : student['attendanceStatus'] ?? 'Unknown',
                      ),
                    );
                  },
                );
              },
            ),

            // Usage History Tab - Calls LabUsageHistoryView directly
            LabUsageHistoryView(lecturerId: lecturerId), // Replaces Placeholder
          ],
        ),
      ),
    );
  }
}
