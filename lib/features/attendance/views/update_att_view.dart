import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:labsync/features/attendance/viewmodels/update_att_viewmodel.dart';
import '../../navigation_bar/navigation_bar.dart';

class StudentDashboardView extends StatelessWidget {
  final String username;
  final String lecturerId;

  const StudentDashboardView({
    super.key,
    required this.username,
    required this.lecturerId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          StudentDashboardViewModel()..checkLabLocation(username, lecturerId),
      child: Consumer<StudentDashboardViewModel>(
        builder: (context, viewModel, child) {
          return ScaffoldWithNavBar(
            currentIndex: 0,
            username: username,
            studentId: '', // Provide a valid ID if needed
            userId: '', // Provide a valid ID if needed
            lecturerId: lecturerId,
            body: Container(
              color: const Color.fromARGB(255, 99, 29, 59),
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(20)),
                    ),
                    child: Center(
                      child: Text(
                        "Welcome, $username",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 99, 29, 59),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 400,
                          maxHeight: 400,
                        ),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: viewModel.isInsideLab
                                    ? Colors.green
                                    : Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                viewModel.isInsideLab
                                    ? Icons.check
                                    : Icons.close,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              viewModel.attendanceStatus,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 20),
                            if (viewModel.isInsideLab)
                              Text(
                                "Current Classroom: ${viewModel.currentClassroom}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
