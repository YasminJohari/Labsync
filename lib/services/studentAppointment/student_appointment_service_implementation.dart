import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labsync/services/studentAppointment/student_appointment_service_abstract.dart';

class StudentAppointmentService implements StudentAppointmentServiceAbstract {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch the lecturer's schedule from Firestore
  Future<List<Map<String, dynamic>>> fetchLecturerSchedule(
      String lecturerId) async {
    try {
      final lecturerDoc =
          await _firestore.collection('lecturers').doc(lecturerId).get();

      if (lecturerDoc.exists) {
        final scheduleData = lecturerDoc.data()?['schedule'] as List<dynamic>?;
        if (scheduleData != null) {
          // Filter out only "Booked" appointments
          return scheduleData
              .where((e) => e['status'] != 'Booked') // Hide "Booked" times
              .map((e) => {
                    'date': e['date'],
                    'time': e['time'],
                    'status': e['status'] // Keep the status for reference
                  })
              .toList();
        }
      }
    } catch (e) {
      print("Error fetching lecturer schedule: $e");
    }
    return [];
  }

  Future<void> updateAppointmentStatus(
      String lecturerId, String date, String time, String status) async {
    try {
      final lecturerDocRef = _firestore.collection('lecturers').doc(lecturerId);

      // Fetch current schedule
      final lecturerDoc = await lecturerDocRef.get();
      if (lecturerDoc.exists) {
        final scheduleData = List<Map<String, dynamic>>.from(
            lecturerDoc.data()?['schedule'] ?? []);

        // Find and update the specific slot
        final updatedSchedule = scheduleData.map((schedule) {
          if (schedule['date'] == date && schedule['time'] == time) {
            return {
              'date': schedule['date'],
              'time': schedule['time'],
              'status': status, // Update status
            };
          }
          return schedule;
        }).toList();

        // Write updated schedule back to Firestore
        await lecturerDocRef.update({'schedule': updatedSchedule});
      }
    } catch (e) {
      throw Exception("Error updating appointment status: $e");
    }
  }
}
