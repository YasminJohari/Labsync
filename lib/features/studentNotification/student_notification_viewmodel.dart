// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:labsync/models/appointment_model.dart';
import 'package:labsync/services/studentNotification/student_notification_service.dart';
import 'package:map_mvvm/view/viewmodel.dart';

class StudentNotificationViewModel extends Viewmodel {
  final StudentNotificationServiceInterface _studentNotificationService;

  StudentNotificationViewModel(this._studentNotificationService);

  List<Appointment> _notifications = [];

  List<Appointment> get notifications => _notifications;
  bool get hasNotifications => _notifications.isNotEmpty;

  Future<void> fetchNotifications(String studentId) async {
    print("student id notification: $studentId");
    if (studentId.isEmpty) {
      debugPrint("No studentId found.");
      return; // Early exit if no studentId
    }

    final now = DateTime.now();
    final todayString = DateFormat('yyyy-MM-dd').format(now);

    try {
      // Fetch appointments using the service
      final appointments = await _studentNotificationService
          .fetchUpcomingAppointments(studentId);

      // Filter by today's date and time
      _notifications = appointments.where((appointment) {
        try {
          final appointmentDate = appointment.date;
          final appointmentTime = appointment.time;

          // Check if date matches today and time is in the future
          return appointmentDate != null &&
              appointmentTime != null &&
              DateFormat('yyyy-MM-dd').format(appointmentDate) == todayString &&
              appointmentTime.isAfter(now);
        } catch (e) {
          debugPrint("Error processing appointment data: $e");
          return false; // Exclude invalid data
        }
      }).toList();
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    }
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
