import 'package:flutter/material.dart';
import 'package:labsync/services/lecturerSchedule/lecturer_schedule_abstract.dart';
import 'package:labsync/services/updateSchedule/update_schedule_service_abstract.dart';
import 'package:map_mvvm/view/viewmodel.dart';

class LecturerScheduleViewModel extends Viewmodel {  // Extend Viewmodel
  final LecturerScheduleServiceInterface _service;

  LecturerScheduleViewModel(
      LecturerScheduleServiceAbstract lecturerScheduleServiceAbstract,
      {required LecturerScheduleServiceInterface service})
      : _service = service;

  final Map<String, List<String>> _lecturerSchedule = {};
  Map<String, List<String>> get lecturerSchedule => _lecturerSchedule;

  DateTime? _selectedDay;
  DateTime? get selectedDay => _selectedDay;

  TimeOfDay _selectedTime = TimeOfDay.now();
  TimeOfDay get selectedTime => _selectedTime;

  List<String> _availableTimes = [];
  List<String> get availableTimes => _availableTimes;

  Future<void> fetchSchedule(String lecturerId) async {
    try {
      final schedule = await _service.fetchSchedule(lecturerId);
      _lecturerSchedule.clear();
      _lecturerSchedule.addAll(schedule);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching schedule: $e");
    }
  }

  Future<List<String>> getTimesForDate(String lecturerId, String date) async {
    if (_lecturerSchedule.containsKey(date)) {
      return _lecturerSchedule[date]!; 
    }
    await fetchSchedule(lecturerId);
    return _lecturerSchedule[date] ?? [];
  }

  void setSelectedDay(DateTime? selectedDay) {
    _selectedDay = selectedDay;
    notifyListeners();
  }

  void setSelectedTime(TimeOfDay selectedTime) {
    _selectedTime = selectedTime;
    notifyListeners();
  }

  void updateAvailableTimes(List<String> times) {
    _availableTimes = times;
    notifyListeners();
  }

  Future<void> addTimeSlot(String lecturerId, String date, String time) async {
    try {
      await _service.addTimeSlot(lecturerId, date, time);
      if (_lecturerSchedule.containsKey(date)) {
        _lecturerSchedule[date]!.add(time);
      } else {
        _lecturerSchedule[date] = [time];
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> removeTimeSlot(
      String lecturerId, String date, String time) async {
    try {
      await _service.removeTimeSlot(lecturerId, date, time);
      if (_lecturerSchedule.containsKey(date)) {
        _lecturerSchedule[date]!.remove(time);
        if (_lecturerSchedule[date]!.isEmpty) {
          _lecturerSchedule.remove(date);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
