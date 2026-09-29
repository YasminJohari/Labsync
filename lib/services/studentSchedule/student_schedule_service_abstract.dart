abstract class StudentScheduleServiceAbstract {
  Future<List<Map<String, dynamic>>> fetchSchedules(String studentId);
  //Future<void> bookAppointment(String scheduleId);
}
