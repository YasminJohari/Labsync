import 'package:flutter/material.dart';
import 'package:labsync/configs/services_locators.dart';
import 'package:labsync/models/appointment_model.dart';
import 'package:labsync/services/notificationRequest/notification_request_service.dart';
import 'package:map_mvvm/view/viewmodel.dart';

class NotificationViewModel extends Viewmodel {
  final NotificationServiceInterface _notificationService =
      serviceLocator<NotificationServiceInterface>();

  List<Appointment> appointmentRequests = [];
  bool isRecommendationMode = false;

  @override
  void init() {
    super.init();
    // Fetch notifications automatically when initialized
    fetchNotificationsOnInit();
  }

  /// Fetch notifications during initialization
  Future<void> fetchNotificationsOnInit() async {
    await update(() async {
      try {
        // Default to fetching pending appointments during init
        appointmentRequests =
            await _notificationService.fetchPendingAppointments("");
      } catch (e) {
        debugPrint('Error fetching notifications on init: $e');
      }
    });
  }

  /// Fetch pending notifications for a specific lecturer
  Future<void> fetchNotifications(String lecturerId) async {
    await update(() async {
      isRecommendationMode = false;

      try {
        appointmentRequests =
            await _notificationService.fetchPendingAppointments(lecturerId);
      } catch (e) {
        debugPrint('Error fetching notifications: $e');
      }
    });
  }

  /// Fetch recommended appointments for a specific lecturer
  Future<void> fetchRecommendedAppointments(String lecturerId) async {
    await update(() async {
      isRecommendationMode = true;

      try {
        appointmentRequests =
            await _notificationService.fetchRecommendedAppointments(lecturerId);
      } catch (e) {
        debugPrint('Error fetching recommended appointments: $e');
      }
    });
  }
}