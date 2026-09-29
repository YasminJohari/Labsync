import 'package:flutter/material.dart';
import 'package:labsync/configs/services_locators.dart';
import 'package:labsync/models/appointment_model.dart';
import 'package:labsync/models/work_progress.dart';
import 'package:labsync/services/activityHistory/activity_history_service.dart';
import 'package:map_mvvm/view/viewmodel.dart';

class ActivityHistoryViewModel extends Viewmodel {
  final ActivityHistoryServiceInterface _activityHistoryService =
      serviceLocator<ActivityHistoryServiceInterface>();

  List<Appointment> _appointments = [];
  List<WorkProgress> _workProgress = [];
  bool _isLoading = false;
  bool _appointmentsLoaded = false;
  bool _workProgressLoaded = false;

  ActivityHistoryViewModel();

  List<Appointment> get appointments => _appointments;
  List<WorkProgress> get workProgress => _workProgress;
  bool get isLoading => _isLoading;

  void _setLoading(bool isLoading) {
    if (_isLoading != isLoading) {
      _isLoading = isLoading;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> fetchAppointments(String lecturerId) async {
    if (_appointmentsLoaded) return; // Avoid fetching again if already loaded
    _setLoading(true);

    try {
      _appointments =
          await _activityHistoryService.getLecturerActivities(lecturerId);
      _appointmentsLoaded = true; // Mark as loaded
    } catch (e) {
      _appointments = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchWorkProgress(String lecturerId) async {
    if (_workProgressLoaded) return; // Avoid fetching again if already loaded
    _setLoading(true);

    try {
      _workProgress =
          await _activityHistoryService.getWorkProgressWithComments(lecturerId);
      _workProgressLoaded = true; // Mark as loaded
    } catch (e) {
      _workProgress = [];
    } finally {
      _setLoading(false);
    }
  }
}
