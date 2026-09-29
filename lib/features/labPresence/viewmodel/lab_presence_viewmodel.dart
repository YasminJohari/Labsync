import 'package:flutter/material.dart';
import 'package:labsync/configs/services_locators.dart';
import 'package:labsync/services/labPresence/presence_abstract.dart';

class LabPresenceViewModel extends ChangeNotifier {
  final String lecturerId;
  final LabPresenceServiceAbstract _attendanceService =
      serviceLocator<LabPresenceServiceAbstract>();

  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  LabPresenceViewModel({required this.lecturerId});

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get students => _students;

  Future<void> fetchStudentsInLab() async {
    _isLoading = true;
    notifyListeners();

    final allStudents = await _attendanceService.fetchStudents(lecturerId);
    _students = allStudents
        .where((student) =>
            student['attendanceStatus'] == 'You are inside the lab building.')
        .toList();

    _isLoading = false;
    notifyListeners();
  }
}
