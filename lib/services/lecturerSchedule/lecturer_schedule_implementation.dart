import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labsync/services/lecturerSchedule/lecturer_schedule_abstract.dart';

class LecturerScheduleServiceImplementation
    implements LecturerScheduleServiceAbstract {
  final FirebaseFirestore firestore;

  LecturerScheduleServiceImplementation(this.firestore);

  @override
  Future<List<Map<String, dynamic>>> fetchScheduleWithRequests(
      String lecturerId) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('appointments')
          .where('lecturerId', isEqualTo: lecturerId)
          .get();

      return querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          "id": doc.id,
          "date": data['date'],
          "time": data['time'],
          "reason": data['reason'],
          "notes": data['notes'],
          "status": data['status'] ?? 'No status',
          "studentId": data['studentId'],
          "username": data['username'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching schedule: $e');
    }
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await firestore.collection('appointments').doc(appointmentId).delete();
    } catch (e) {
      throw Exception('Error cancelling appointment: $e');
    }
  }

  @override
  Future<void> updateLecturerStatusToAvailable(
      String lecturerId, String dateStr, String timeStr) async {
    try {
      final lecturerDocRef = firestore.collection('lecturers').doc(lecturerId);
      final lecturerDoc = await lecturerDocRef.get();
      if (lecturerDoc.exists) {
        final scheduleData = List<Map<String, dynamic>>.from(
            lecturerDoc.data()?['schedule'] ?? []);
        final updatedSchedule = scheduleData.map((schedule) {
          if (schedule['date'] == dateStr && schedule['time'] == timeStr) {
            return {
              'date': schedule['date'],
              'time': schedule['time'],
              'status': 'available',
            };
          }
          return schedule;
        }).toList();
        await lecturerDocRef.update({'schedule': updatedSchedule});
      }
    } catch (e) {
      throw Exception('Error updating lecturer status to available: $e');
    }
  }
}
