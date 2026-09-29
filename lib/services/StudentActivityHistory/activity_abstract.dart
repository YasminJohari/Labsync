abstract class StudentActivityHistoryServiceAbstract {
  Future<List<Map<String, dynamic>>> fetchAttendanceHistory(String studentId);
  Future<List<Map<String, dynamic>>> fetchAppointments(String studentId);
  Future<List<Map<String, dynamic>>> fetchWorkProgress(String studentId);
}
