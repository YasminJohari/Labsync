import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labsync/services/labPresence/presence_abstract.dart';

class FirebaseLabAttendanceService implements LabPresenceServiceAbstract {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Map<String, dynamic>>> fetchStudents(String lecturerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('students')
          .where('lecturerId', isEqualTo: lecturerId)
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'name': doc['name'] ?? 'Unknown',
          'attendanceStatus': doc['attendanceStatus'] ?? 'Unknown',
          'currentClassroom': doc['currentClassroom'] ?? 'Unknown Classroom',
        };
      }).toList();
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAttendanceHistory(
      String lecturerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('attendance_history')
          .where('lecturerId', isEqualTo: lecturerId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'username': doc['username'] ?? 'Unknown',
          'timestamp': doc['timestamp']?.toDate().toString() ?? 'Unknown',
          'attendanceStatus': doc['attendanceStatus'] ?? 'Unknown',
        };
      }).toList();
    } catch (e) {
      print('Error fetching attendance history: $e');
      return [];
    }
  }

  @override
  Future<void> storeToUsageHistory(Map<String, dynamic> student) async {
    try {
      await _firestore.collection('attendance_history').add({
        'username': student['name'],
        'lecturerId': student['lecturerId'],
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error storing to usage history: $e");
    }
  }
}
