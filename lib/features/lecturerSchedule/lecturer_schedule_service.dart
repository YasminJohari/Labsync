import 'package:cloud_firestore/cloud_firestore.dart';

class LecturerScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch the schedule of a lecturer
  Future<List<Map<String, dynamic>>> getLecturerSchedule(
      String lecturerId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> scheduleSnapshot = await _firestore
          .collection('lecturer_schedules')
          .where('lecturerId', isEqualTo: lecturerId)
          .get();

      List<Map<String, dynamic>> schedules = [];
      for (var doc in scheduleSnapshot.docs) {
        schedules.add(doc.data());
      }
      return schedules;
    } catch (e) {
      print("Error fetching schedule: $e");
      return [];
    }
  }
}
