import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labsync/services/labHistory/presence_history_abstract.dart';

class FirebaseAttendanceHistoryServices
    implements AttendanceHistoryServiceAbstract {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Map<String, dynamic>>> fetchAttendanceHistory(
      String lecturerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('attendance_history')
          .where('lecturerId', isEqualTo: lecturerId)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'username': doc['username'] ?? 'Unknown',
          'timestamp': doc['timestamp']?.toDate() ?? 'Unknown',
          'attendanceStatus': doc['status'] ?? 'Unknown',
        };
      }).toList();
    } catch (e) {
      print("Error fetching attendance history: $e");
      return [];
    }
  }
}
