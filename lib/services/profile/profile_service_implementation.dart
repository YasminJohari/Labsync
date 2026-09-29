import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_service_abstract.dart';

class ProfileServiceImpl implements ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> getUserInfo(String studentId) async {
    final userRef = _firestore
        .collection('users')
        .where('username', isEqualTo: studentId)
        .limit(1);

    final querySnapshot = await userRef.get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data();
    }
    return null;
  }

  @override
  Future<void> updateAttendanceStatus(String studentId, String status) async {
    final studentRef = _firestore
        .collection('students')
        .where('name', isEqualTo: studentId)
        .limit(1);

    final querySnapshot = await studentRef.get();
    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      await _firestore.collection('students').doc(docId).update({
        'attendanceStatus': 'You are not inside the lab building',
      });
    }
  }

  @override
  Future<void> recordLastAccessTime(String studentId) async {
    final attendanceHistoryRef = _firestore.collection('attendance_history');

    // Add a record to the attendance_history collection with the last access time
    await attendanceHistoryRef.add({
      'studentId': studentId,
      'lastAccessTime': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteCacheUser(String studentId) async {
    try {
      // Query cached_users collection based on username
      final cachedUserRef = _firestore
          .collection('cached_users')
          .where('username', isEqualTo: studentId)
          .limit(1);

      final querySnapshot = await cachedUserRef.get();
      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        // Delete cached user document
        await _firestore.collection('cached_users').doc(docId).delete();
        print('Cached user deleted successfully.');
      } else {
        print('No cached user found for username: $studentId');
      }
    } catch (e) {
      print('Failed to delete cached user: $e');
    }
  }
}