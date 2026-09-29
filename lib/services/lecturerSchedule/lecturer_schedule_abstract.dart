abstract class LecturerScheduleServiceAbstract {
  Future<List<Map<String, dynamic>>> fetchScheduleWithRequests(
      String lecturerId);
  Future<void> cancelAppointment(String appointmentId);
  Future<void> updateLecturerStatusToAvailable(
      String lecturerId, String dateStr, String timeStr);
}
