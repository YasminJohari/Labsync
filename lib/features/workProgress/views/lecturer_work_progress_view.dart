import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labsync/features/workProgress/viewmodels/lecturer_work_progress_viewmodel.dart';

class LecturerWorkProgressView extends StatelessWidget {
  final String lecturerId;

  const LecturerWorkProgressView({Key? key, required this.lecturerId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel =
        Provider.of<LecturerWorkProgressViewModel>(context, listen: false);
    if (!viewModel.hasFetched) {
      Future.microtask(() => viewModel.fetchWorkProgress());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Work Progress"),
      ),
      body: Consumer<LecturerWorkProgressViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.workProgressList.isEmpty) {
            return const Center(child: Text("No work progress available."));
          }

          return ListView.builder(
            itemCount: viewModel.workProgressList.length,
            itemBuilder: (context, index) {
              final item = viewModel.workProgressList[index];
              final fileUrl = item['fileUrl'];
              final studentId = item['studentId'];
              final workId = item['id'];
              final TextEditingController commentController =
                  TextEditingController();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (studentId != null)
                        Text(
                          'Student: $studentId',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Project Name: ${item['progressTitle'] ?? 'Unnamed Task'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Project Description: ${item['progressDescription'] ?? 'No Details'}',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Color.fromARGB(255, 101, 97, 97),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Comment: ${item['comments']}',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (fileUrl != null)
                        TextButton.icon(
                          onPressed: () async {
                            await viewModel.downloadFileFromGoogleDrive(
                                fileUrl, context);
                          },
                          icon: const Icon(Icons.download),
                          label: const Text("Download File"),
                        ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          labelText: 'Enter your comment',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () async {
                            final comment = commentController.text.trim();

                            if (workId == null || workId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Invalid work ID')),
                              );
                              return;
                            }

                            if (comment.isNotEmpty) {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('work_progress')
                                    .doc(workId)
                                    .update({'comments': comment});

                                commentController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Comment saved successfully!')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Failed to save comment: $e')),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please enter a comment to save.')),
                              );
                            }
                          },
                          child: const Text("Save Comment"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
