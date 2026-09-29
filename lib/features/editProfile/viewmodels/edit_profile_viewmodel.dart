import 'package:labsync/configs/services_locators.dart';
import 'package:labsync/services/EditProfile/edit_profile_service_abstract.dart';
import 'package:map_mvvm/view/viewmodel.dart';

class EditProfileViewModel extends Viewmodel {
  final EditProfileService _editProfileService =
      serviceLocator<EditProfileService>();

  final List<String> faculties = [
    'FKM',
    'FC',
    'FABU',
    'FKE',
    'PSY',
    'FKA',
    'FSSH',
  ];

  Future<Map<String, dynamic>> getUserInfo(String studentId) async {
    return await _editProfileService.getUserInfo(studentId);
  }

  Future<void> updateProfile(String studentId, Map<String, String> data) async {
    await _editProfileService.updateProfile(studentId, data);
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    await _editProfileService.changePassword(currentPassword, newPassword);
  }

  String? validateProgrammeCode(String? value) {
    final pattern = RegExp(r'^\d\/[A-Z]{5}$');
    if (value == null || value.isEmpty) {
      return 'Programme code is required.';
    }
    if (!pattern.hasMatch(value)) {
      return 'Invalid programme code format (e.g., 2/SECVH).';
    }
    return null;
  }

  String? validateFaculty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a faculty.';
    }
    return null;
  }
}
