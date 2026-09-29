import 'package:flutter/material.dart';
import 'package:labsync/configs/services_locators.dart';
import 'package:labsync/services/signUp/sign_up_service_abstract.dart';
import 'package:map_mvvm/view/viewmodel.dart';

class SignUpViewmodel extends Viewmodel {
  final SignUpService _authService = serviceLocator<SignUpService>();

  String fullName = '';
  String matricNumber = '';
  String email = '';
  String password = '';
  String username = '';
  String role = 'Student';
  String selectedLecturerId = '';
  List<String> lecturerList = [];

  Future<void> fetchLecturers() async {
    try {
      // Fetch lecturer data from the service
      lecturerList = await _authService.fetchLecturers();
      notifyListeners(); // Notify the UI that the lecturer list has been updated
    } catch (e) {}
  }

  // Change the role (Student or Lecturer)
  void changeRole(String newRole) {
    role = newRole;
    selectedLecturerId = '';
    notifyListeners();
  }

  // Change the selected lecturer (only applicable if role is Student)
  void changeLecturer(String newLecturerId) {
    selectedLecturerId = newLecturerId;
    notifyListeners();
  }

  // Sign up user with the provided information
  Future<void> signUp({
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    try {
      await _authService.signUp(
        fullName,
        matricNumber,
        email,
        password,
        username,
        role,
        selectedLecturerId,
      );
      onSuccess(); // Call success callback
    } catch (e) {
      onError('Sign-up failed: ${e.toString()}'); // Call error callback
    }
  }
}
