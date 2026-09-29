import 'package:flutter/material.dart';
import 'package:labsync/configs/services_locators.dart';
import 'package:labsync/services/labHistory/presence_history_abstract.dart';

class HistoryViewModel extends ChangeNotifier {
  final AttendanceHistoryServiceAbstract _attendanceService =
      serviceLocator<AttendanceHistoryServiceAbstract>();

  bool isLoading = false;
  List<Map<String, dynamic>> attendanceHistory = [];

  Future<void> fetchAttendanceHistory(String lecturerId) async {
    isLoading = true;
    notifyListeners();

    try {
      attendanceHistory =
          await _attendanceService.fetchAttendanceHistory(lecturerId);
    } catch (e) {
      print("Error fetching attendance history: $e");
      attendanceHistory = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
