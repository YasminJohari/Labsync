import 'package:labsync/services/profile/profile_service_abstract.dart';
import 'package:map_mvvm/view/viewmodel.dart';

class ProfileViewModel extends Viewmodel {
  final ProfileService _profileService;

  ProfileViewModel(this._profileService);

  List<Map<String, String>> userInfo = [];
  bool dataLoaded = false;

  Future<void> fetchUserInfo(String userId) async {
    if (busy) return; // Avoid duplicate calls

    turnBusy();
    try {
      final data = await _profileService.getUserInfo(userId);

      final Map<String, String> studentDisplayNameMap = {
        'fullName': 'Full Name',
        'matricNumber': 'Matric Number',
        'programmeCode': 'Programme Code',
        'faculty': 'Faculty',
        'email': 'Email',
        'role': 'Role',
        'username': 'Username',
      };

      final Map<String, String> lecturerDisplayNameMap = {
        'fullName': 'Full Name',
        'faculty': 'Faculty',
        'roomNo': 'Room No',
        'email': 'Email',
        'lecturerId': 'Lecturer ID',
        'role': 'Role',
        'username': 'Username',
      };

      List<String> fieldOrder;
      Map<String, String> displayNameMap;

      if (data?['role'] == 'Student') {
        fieldOrder = [
          'fullName',
          'matricNumber',
          'programmeCode',
          'faculty',
          'email',
          'role',
          'username',
        ];
        displayNameMap = studentDisplayNameMap;
      } else if (data?['role'] == 'Lecturer') {
        fieldOrder = [
          'fullName',
          'faculty',
          'roomNo',
          'email',
          'lecturerId',
          'role',
          'username',
        ];
        displayNameMap = lecturerDisplayNameMap;
      } else {
        userInfo = [];
        return;
      }

      userInfo = fieldOrder.map((key) {
        return {
          'label': displayNameMap[key] ?? key,
          'value': (data?[key] ?? 'Not available').toString(),
        };
      }).toList();

      dataLoaded = true;
    } catch (e) {
      userInfo = [];
      rethrow;
    } finally {
      turnIdle();
    }
  }

  Future<void> logout(String userId) async {
    turnBusy();
    try {
      await _profileService.updateAttendanceStatus(
          userId, 'You are not inside the lab building');
      await _profileService.recordLastAccessTime(userId);
      await _profileService.deleteCacheUser(userId);
    } finally {
      turnIdle();
    }
  }
}
