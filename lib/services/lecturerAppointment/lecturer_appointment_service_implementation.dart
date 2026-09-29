import 'package:cloud_firestore/cloud_firestore.dart';
import 'lecturer_appointment_service_abstract.dart';

class LecturerAppointmentService implements LecturerAppointmentServiceAbstract {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Map<String, dynamic>>> getStudentsForLecturer(
      String lecturerId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> usersSnapshot = await _firestore
          .collection('users')
          .where('lecturerId', isEqualTo: lecturerId)
          .where('role', isEqualTo: 'Student')
          .get();
      print(
          'Firestore query results: ${usersSnapshot.docs.length} students found.');

      List<Map<String, dynamic>> students = [];

      for (var userDoc in usersSnapshot.docs) {
        // Check if the lecturerId is correctly matched
        print(
            'User: ${userDoc['username']} with lecturerId: ${userDoc['lecturerId']}');
        String userId = userDoc.id;
        DocumentSnapshot<Map<String, dynamic>> studentDoc =
            await _firestore.collection('students').doc(userId).get();

        if (studentDoc.exists) {
          final studentData = studentDoc.data()!;
          final attendanceStatus = studentData['attendanceStatus'];

          students.add({
            'username': userDoc['username'],
            'attendanceStatus': attendanceStatus,
            'currentClassroom': studentData['currentClassroom'] ?? 'None',
            'location': studentData['location'],
            'timestamp': studentData['timestamp'],
          });
        }
      }

      return students;
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  @override
  Future<void> deleteStudent(String studentId) async {
    try {
      // Step 1: Retrieve the user's UID by matching the username in 'users'
      final userSnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: studentId)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw Exception('No user found with the given studentId');
      }

      final uid = userSnapshot.docs.first.id;

      // Step 2: Delete the user from the 'users' collection
      await _firestore.collection('users').doc(uid).delete();

      // Step 3: Check and delete the student from the 'students' collection
      final studentDoc = await _firestore.collection('students').doc(uid).get();

      if (studentDoc.exists && studentDoc.id == uid) {
        await _firestore.collection('students').doc(uid).delete();
      } else {
        throw Exception(
            'No matching student found in the "students" collection.');
      }
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }
}
