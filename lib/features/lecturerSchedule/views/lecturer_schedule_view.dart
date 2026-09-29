import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:labsync/features/lecturerSchedule/viewmodels/lecturer_schedule_viewmodel.dart';

class LecturerScheduleView extends StatelessWidget {
  final String lecturerId;

  const LecturerScheduleView({super.key, required this.lecturerId});

  @override
  Widget build(BuildContext context) {
    // Use context.watch to listen to changes in the view model
    final viewModel = context.watch<LecturerScheduleViewModel1>();

    // Fetch data on initialization, if it hasn't been fetched yet
    if (!viewModel.isInitialized) {
      viewModel.fetchScheduleWithRequests(lecturerId);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Schedule",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: const Color.fromARGB(255, 99, 29, 59),
        elevation: 4,
      ),
      body: Consumer<LecturerScheduleViewModel1>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.scheduleWithRequests.isEmpty) {
            return const Center(
              child: Text(
                "No schedule data available or an error occurred.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.scheduleWithRequests.length,
                itemBuilder: (context, index) {
                  final schedule = viewModel.scheduleWithRequests[index];

                  // Ensure that all fields are non-null, provide default values if necessary
                  final date = schedule["date"] ?? "No date available";
                  final time = schedule["time"] ?? "No time available";
                  final reason = schedule["reason"] ?? "No reason provided";
                  final status = schedule["status"] ?? "Unknown";

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        date, // Use non-null date
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        "$time - $reason", // Use non-null time and reason
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Chip(
                        label: Text(
                          status, // Use non-null status
                          style: TextStyle(
                            color: status == "Approved"
                                ? Colors.green
                                : (status == "Pending"
                                    ? Colors.orange
                                    : Colors.red),
                          ),
                        ),
                        backgroundColor: Colors.transparent,
                        side: BorderSide(
                          color: status == "Approved"
                              ? Colors.green
                              : (status == "Pending"
                                  ? Colors.orange
                                  : Colors.red),
                        ),
                      ),
                      onTap: () {
                        // Confirm cancellation dialog
                        if (status == "Pending" || status == "Approved") {
                          final viewModel =
                              context.read<LecturerScheduleViewModel1>();

                          // Format the date string (it is already in ISO 8601 format)
                          final formattedDate = date.split(
                              "T")[0]; // Extract the date part "2024-12-30"

                          // Format the time string (extract time part)
                          final formattedTime = time
                              .split("T")[1]
                              .substring(0, 5); // Extract "17:00"

                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                "Cancel Appointment",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: const Text(
                                "Are you sure you want to cancel this appointment?",
                                style: TextStyle(fontSize: 16),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("No"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop(); // Close dialog
                                    await viewModel.cancelAppointment(
                                      schedule["id"], // Pass appointment ID
                                      formattedDate,
                                      formattedTime,
                                      lecturerId, // Pass the lecturerId
                                    );
                                  },
                                  child: const Text("Yes"),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
