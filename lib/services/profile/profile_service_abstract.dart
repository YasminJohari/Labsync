abstract class ProfileService {
  Future<Map<String, dynamic>?> getUserInfo(String studentId);
  Future<void> updateAttendanceStatus(String studentId, String status);
  Future<void> deleteCacheUser(String studentId);
  Future<void> recordLastAccessTime(String studentId);
}