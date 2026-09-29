import 'package:flutter/material.dart';
import 'package:labsync/features/labHistory/viewmodel/lab_history_viewmodel.dart';
import 'package:labsync/main.dart';

class LabUsageHistoryView extends StatelessWidget {
  final String lecturerId;

  const LabUsageHistoryView({super.key, required this.lecturerId});

  @override
  Widget build(BuildContext context) {
    final historyViewModel = serviceLocator<HistoryViewModel>(
      param1: lecturerId,
    );

    return Scaffold(
      body: FutureBuilder(
        future: historyViewModel.fetchAttendanceHistory(lecturerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              historyViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (historyViewModel.attendanceHistory.isEmpty) {
            return const Center(child: Text('No history found.'));
          } else {
            return ListView.builder(
              itemCount: historyViewModel.attendanceHistory.length,
              itemBuilder: (context, index) {
                final record = historyViewModel.attendanceHistory[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(record['username']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text("Date: ${record['timestamp']}")],
                    ),
                    leading: const Icon(Icons.person),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
