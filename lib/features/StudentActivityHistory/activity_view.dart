import 'package:flutter/material.dart';
import 'package:labsync/features/StudentActivityHistory/activity_viewmodel.dart';
import 'package:map_mvvm/view/view.dart';

class StudentActivityHistoryView extends StatelessWidget {
  final String studentId;

  const StudentActivityHistoryView({Key? key, required this.studentId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewWrapper<StudentActivityHistoryViewModel>(
      builder: (context, viewModel) {
        // Perform initialization only if not already loading or initialized
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!viewModel.isLoading &&
              (viewModel.attendanceRecord.isEmpty ||
                  viewModel.appointments.isEmpty ||
                  viewModel.workProgress.isEmpty)) {
            viewModel.initialize(studentId);
          }
        });

        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return DefaultTabController(
          length: 3, // Number of tabs
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Student Activity History'),
              backgroundColor: const Color.fromARGB(255, 99, 29, 59),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Attendance'),
                  Tab(text: 'Appointments'),
                  Tab(text: 'Work Progress'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildAttendanceTab(viewModel), // Attendance tab
                _buildAppointmentTab(viewModel), // Appointments tab
                _buildWorkProgressTab(viewModel), // Work Progress tab
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceTab(StudentActivityHistoryViewModel viewModel) {
    if (viewModel.attendanceRecord.isEmpty) {
      return const Center(
        child: Text(
          'No attendance record available.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.attendanceRecord.length,
      itemBuilder: (context, index) {
        final attendance = viewModel.attendanceRecord[index];
        final lastAccessTime = attendance['lastAccessTime'] as DateTime?;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(
              'Student ID: ${attendance['studentId']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Last Access Time: ${lastAccessTime != null ? "${lastAccessTime.toLocal()}" : 'N/A'}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentTab(StudentActivityHistoryViewModel viewModel) {
    if (viewModel.appointments.isEmpty) {
      return const Center(
        child: Text(
          'No appointments available.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.appointments.length,
      itemBuilder: (context, index) {
        final appointment = viewModel.appointments[index];
        DateTime appointmentDate = DateTime.parse(appointment['date']);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(
              'Student Name: ${appointment['studentId']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Time: ${TimeOfDay.fromDateTime(DateTime.parse(appointment['time'])).format(context)}\n'
              'Date: ${appointmentDate.toLocal().toString().split(' ')[0]}\n'
              'Status: ${appointment['status']}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkProgressTab(StudentActivityHistoryViewModel viewModel) {
    if (viewModel.workProgress.isEmpty) {
      return const Center(
        child: Text(
          'No work progress recorded.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.workProgress.length,
      itemBuilder: (context, index) {
        final workProgress = viewModel.workProgress[index];
        DateTime? workProgressDate = workProgress['submissionDate'];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(
              'Title: ${workProgress['progressTitle']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Description: ${workProgress['progressDescription']}\n'
              'Student ID: ${workProgress['studentId']}\n'
              'Date: ${workProgressDate != null ? workProgressDate.toLocal().toString().split(' ')[0] : 'N/A'}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        );
      },
    );
  }
}
