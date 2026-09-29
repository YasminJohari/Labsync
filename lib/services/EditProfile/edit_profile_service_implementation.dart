import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:labsync/services/EditProfile/edit_profile_service_abstract.dart';

class EditProfileServiceImpl implements EditProfileService {
  @override
  Future<Map<String, dynamic>> getUserInfo(String studentId) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: studentId)
        .limit(1);

    final querySnapshot = await userRef.get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data();
    }
    return {};
  }

  @override
  Future<void> updateProfile(
      String studentId, Map<String, dynamic> data) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: studentId)
        .limit(1);

    final querySnapshot = await userRef.get();
    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .update(data);
    }
  }

  @override
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    try {
      // Re-authenticate the user
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser?.email ?? '',
        password: currentPassword,
      );
      await currentUser?.reauthenticateWithCredential(credential);

      // Update password
      await currentUser?.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}
