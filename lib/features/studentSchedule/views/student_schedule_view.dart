import 'package:flutter/material.dart';
import 'package:labsync/features/studentSchedule/viewmodels/student_schedule_viewmodel.dart';
import 'package:provider/provider.dart';

class StudentScheduleView extends StatelessWidget {
  final String studentId;

  const StudentScheduleView({required this.studentId, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentScheduleViewModel()..fetchSchedules(studentId),
      child: Scaffold(
        appBar: AppBar(
          title: Text("My Schedule - $studentId"),
        ),
        body: Consumer<StudentScheduleViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.lecturerSchedules.isEmpty) {
              return const Center(
                child: Text("No schedules available."),
              );
            }

            return ListView.builder(
              itemCount: viewModel.lecturerSchedules.length,
              itemBuilder: (context, index) {
                final schedule = viewModel.lecturerSchedules[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8), // Card padding
                  elevation: 3, // Shadow effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded edges
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Inner padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date and Time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              schedule["date"], // Date
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              schedule["timeSlot"], // Time slot
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Status
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Status: ${schedule["status"]}", // Status
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: schedule["status"] == "Approved"
                                    ? Colors.green
                                    : (schedule["status"] == "Rejected"
                                        ? Colors.red
                                        : Colors.orange), // Conditional color
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Reason
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.note_alt_outlined,
                              size: 18,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Reason: ${schedule["reason"]}", // Reason
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
