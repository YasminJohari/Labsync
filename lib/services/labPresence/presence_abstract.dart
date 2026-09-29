abstract class LabPresenceServiceAbstract {
  Future<List<Map<String, dynamic>>> fetchStudents(String lecturerId);
  Future<List<Map<String, dynamic>>> fetchAttendanceHistory(String lecturerId);
  Future<void> storeToUsageHistory(Map<String, dynamic> student);
}
