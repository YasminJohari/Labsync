abstract class EditProfileService {
  Future<Map<String, dynamic>> getUserInfo(String studentId);
  Future<void> updateProfile(String studentId, Map<String, dynamic> data);
  Future<void> changePassword(String currentPassword, String newPassword);
}
