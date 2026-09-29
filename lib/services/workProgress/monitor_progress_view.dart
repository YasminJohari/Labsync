import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:labsync/features/workProgress/viewmodels/work_progress_viewmodel.dart';
import 'package:labsync/services/workProgress/work_progress_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MonitorProgress extends StatelessWidget {
  final String lecturerId;

  MonitorProgress({required this.lecturerId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkProgressViewModel(
        WorkProgressService(),
        FirebaseFirestore.instance,
      )..fetchWorkProgressForLecturer(lecturerId),
      child: Consumer<WorkProgressViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (viewModel.workProgressList.isEmpty) {
            return Center(child: Text("No progress submissions."));
          }
          return ListView.builder(
            itemCount: viewModel.workProgressList.length,
            itemBuilder: (context, index) {
              final progress = viewModel.workProgressList[index];
              return ListTile(
                title: Text(progress.progressTitle),
                subtitle: Text(progress.progressDescription),
              );
            },
          );
        },
      ),
    );
  }
}