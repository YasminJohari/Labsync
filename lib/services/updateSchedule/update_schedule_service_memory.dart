// lib/services/updateSchedule/update_schedule_service_memory.dart

import 'package:labsync/services/updateSchedule/update_schedule_service_abstract.dart';

class LecturerScheduleServiceMemory
    implements LecturerScheduleServiceInterface {
  final Map<String, List<String>> _schedule = {};

  @override
  Future<Map<String, List<String>>> fetchSchedule(String lecturerId) async {
    return _schedule; // Returns in-memory schedule data
  }

  @override
  Future<void> addTimeSlot(String lecturerId, String date, String time) async {
    if (_schedule.containsKey(date)) {
      _schedule[date]!.add(time);
    } else {
      _schedule[date] = [time];
    }
  }

  @override
  Future<void> removeTimeSlot(
      String lecturerId, String date, String time) async {
    if (_schedule.containsKey(date)) {
      _schedule[date]!.remove(time);
      if (_schedule[date]!.isEmpty) {
        _schedule.remove(date);
      }
    }
  }
}
