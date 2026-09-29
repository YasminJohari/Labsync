import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:labsync/features/lecturerSchedule/viewmodels/lecturer_schedule_viewmodel.dart';

class StudentLecturerScheduleView extends StatelessWidget {
  final String lecturerId;

  const StudentLecturerScheduleView({super.key, required this.lecturerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lecturer's Schedule"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ChangeNotifierProvider(
        create: (_) => LecturerScheduleViewModel1(lecturerId: lecturerId)
          ..fetchScheduleWithRequests(lecturerId), // Pass the lecturerId here
        child: Consumer<LecturerScheduleViewModel1>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.scheduleWithRequests.isEmpty) {
              return const Center(child: Text("No schedules available."));
            }

            return ListView.builder(
              itemCount: viewModel.scheduleWithRequests.length,
              itemBuilder: (context, index) {
                final schedule = viewModel.scheduleWithRequests[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      "${schedule["day"]}: ${schedule["time"]}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      schedule["requests"] > 0
                          ? "${schedule["requests"]} appointment requests"
                          : "No appointments",
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
