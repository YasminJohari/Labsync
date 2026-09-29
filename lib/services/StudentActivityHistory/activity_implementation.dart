import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labsync/services/StudentActivityHistory/activity_abstract.dart'; // Import Timestamp

class StudentActivityHistoryServiceImpl
    implements StudentActivityHistoryServiceAbstract {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Map<String, dynamic>>> fetchAttendanceHistory(
      String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('attendance_history') // Example collection
          .where('studentId', isEqualTo: studentId)
          .get();

      // Convert Firestore data to DateTime (handling Timestamp to DateTime conversion)
      return snapshot.docs.map((doc) {
        var data = doc.data();
        var lastAccessTime = data['lastAccessTime'] as Timestamp?;
        return {
          ...data,
          'lastAccessTime':
              lastAccessTime?.toDate(), // Convert Timestamp to DateTime
        };
      }).toList();
    } catch (e) {
      print('Error fetching attendance history: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAppointments(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('studentId', isEqualTo: studentId)
          .where('status', whereIn: ['Approved', 'Rejected']).get();

      print(
          'Appointments query snapshot: ${querySnapshot.docs.length} documents found.');

      if (querySnapshot.docs.isEmpty) {
        print('No appointments found for studentId: $studentId');
        return []; // Return an empty list if no data
      }

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching appointments: $e');
      return []; // Return an empty list if an error occurs
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWorkProgress(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('work_progress')
          .where('studentId', isEqualTo: studentId)
          .get();

      // Map the query results to a list of maps with only the required fields
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Convert the submissionDate from Firestore Timestamp to DateTime
        final submissionDate = data['submissionDate'] != null
            ? (data['submissionDate'] as Timestamp).toDate()
            : null;

        return {
          'progressTitle': data['progressTitle'],
          'progressDescription': data['progressDescription'],
          'studentId': data['studentId'],
          'submissionDate': submissionDate, // DateTime
        };
      }).toList();
    } catch (e) {
      print('Error fetching work progress: $e');
      throw Exception('Error fetching work progress: $e');
    }
  }
}
