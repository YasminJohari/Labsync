abstract class AttendanceHistoryServiceAbstract {
  Future<List<Map<String, dynamic>>> fetchAttendanceHistory(String lecturerId);
}
