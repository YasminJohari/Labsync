abstract class StudentAppointmentServiceAbstract {
  Future<List<Map<String, dynamic>>> fetchLecturerSchedule(String lecturerId);
  Future<void> updateAppointmentStatus(
      String lecturerId, String date, String time, String status);
}
