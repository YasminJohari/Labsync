import 'package:flutter/material.dart';
import 'package:labsync/features/attendance/views/update_att_view.dart';
import 'package:labsync/features/lecturerDashboard/views/lecturer_dashboard_view.dart';
import 'package:labsync/services/login/auth_service_abstract.dart';
import 'package:map_mvvm/view/viewmodel.dart'; // Import the correct package for Viewmodel

class LoginViewModel extends Viewmodel {
  final AuthServiceAbstract _authService;

  LoginViewModel(this._authService);

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<void> checkCachedUser(BuildContext context) async {
    try {
      final user = await _authService.getCachedUser();
      if (user != null) {
        final role = user.role;
        final lecturerId = user.lecturerId ?? '';

        if (role == 'Student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDashboardView(
                username: user.username,
                lecturerId: lecturerId,
              ),
            ),
          );
        } else if (role == 'Lecturer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LecturerDashboardView(
                  lecturerId: lecturerId, username: user.username),
            ),
          );
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to check cached user: ${e.toString()}';
      notifyListeners(); // Ensure notifyListeners is called for UI updates
    }
  }

  // Perform login logic
  Future<void> login(
      String username, String password, BuildContext context) async {
    try {
      final user = await _authService.login(username, password);
      if (user != null) {
        final role = user.role;
        final lecturerId = user.lecturerId ?? '';

        if (role == 'Student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDashboardView(
                username: user.username,
                lecturerId: lecturerId,
              ),
            ),
          );
        } else if (role == 'Lecturer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LecturerDashboardView(
                  lecturerId: lecturerId, username: username),
            ),
          );
        }
      } else {
        _errorMessage = 'Invalid username or password';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> forgotPassword(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset Password"),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(hintText: "Enter your email"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await _authService.forgotPassword(emailController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password reset email sent!")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              },
              child: const Text("Send Email"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
