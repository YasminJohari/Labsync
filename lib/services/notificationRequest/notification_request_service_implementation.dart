import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labsync/models/appointment_model.dart';
import 'package:labsync/services/notificationRequest/notification_request_service.dart';

class NotificationService implements NotificationServiceInterface {
  final FirebaseFirestore firestore;

  NotificationService(this.firestore);

  @override
  Future<List<Appointment>> fetchPendingAppointments(String lecturerId) async {
    try {
      final snapshot = await firestore
          .collection('appointments')
          .where('lecturerId', isEqualTo: lecturerId)
          .where('status', isEqualTo: 'Pending')
          .get();

      return snapshot.docs.map((doc) {
        return Appointment.fromJson(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching pending appointments: $e');
    }
  }

  @override
  Future<List<Appointment>> fetchRecommendedAppointments(
      String lecturerId) async {
    try {
      final snapshot = await firestore
          .collection('appointments')
          .where('lecturerId', isEqualTo: lecturerId)
          .where('status', isEqualTo: 'Pending')
          .orderBy('date')
          .orderBy('time')
          .get();

      return snapshot.docs.map((doc) {
        return Appointment.fromJson(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching recommended appointments: $e');
    }
  }
}
