// lib/services/updateSchedule/update_schedule_service_abstract.dart

abstract class LecturerScheduleServiceInterface {
  Future<Map<String, List<String>>> fetchSchedule(String lecturerId);
  Future<void> addTimeSlot(String lecturerId, String date, String time);
  Future<void> removeTimeSlot(String lecturerId, String date, String time);
}
