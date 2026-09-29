import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:labsync/services/workProgress/submit_progress.dart';
import 'package:labsync/features/workProgress/viewmodels/student_work_progress_viewmodel.dart';

class StudentWorkProgressView extends StatelessWidget {
  final String studentId;
  final String lecturerId;

  const StudentWorkProgressView({
    required this.studentId,
    required this.lecturerId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<StudentWorkProgressViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text("$studentId's Work Progress"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: viewModel.workProgressStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error loading progress data."));
            }

            final workProgressList = snapshot.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: (workProgressList == null || workProgressList.isEmpty)
                      ? Center(child: Text("No work progress uploaded yet."))
                      : ListView.builder(
                          itemCount: workProgressList.length,
                          itemBuilder: (context, index) {
                            final progress = workProgressList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              child: ListTile(
                                leading: Icon(Icons.file_present),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Project Title: ${progress['progressTitle'] ?? "Untitled"}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Project Description: ${progress['progressDescription'] ?? "No description available"}',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: const Color.fromARGB(
                                            255, 101, 97, 97),
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    // Display Lecturer's Comment if available
                                    if (progress['comments'] != null &&
                                        progress['comments'].isNotEmpty)
                                      Text(
                                        'Lecturer Comment: ${progress['comments']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey,
                                          fontSize: 14,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.download),
                                  onPressed: () async {
                                    final fileUrl = progress['fileUrl'];
                                    viewModel.downloadFileFromGoogleDrive(
                                        fileUrl, context);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
                SizedBox(height: 10),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubmitProgress(
                            studentId: studentId,
                            lecturerId: lecturerId,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.upload_file),
                    label: Text("Submit Your Progress"),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
