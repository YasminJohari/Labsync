import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labsync/models/appointment_model.dart';
import 'package:labsync/models/work_progress.dart';
import 'package:labsync/services/activityHistory/activity_history_service.dart';

class ActivityHistoryService implements ActivityHistoryServiceInterface {
  @override
  Future<List<Appointment>> getLecturerActivities(String lecturerId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('lecturerId', isEqualTo: lecturerId)
          .where('status', isEqualTo: 'Approved')
          .get();

      // Map Firestore data into Appointment objects
      return snapshot.docs
          .map((doc) => Appointment.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching appointments: $e');
    }
  }

  @override
  Future<List<WorkProgress>> getWorkProgressWithComments(
      String lecturerId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('work_progress')
          .where('lecturerId', isEqualTo: lecturerId)
          .where('comments', isNotEqualTo: '')
          .get();

      return snapshot.docs
          .map((doc) => WorkProgress.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error fetching work progress: $e');
    }
  }
}
