import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labsync/models/appointment_model.dart';
import 'package:labsync/services/studentNotification/student_notification_service.dart';

class StudentNotificationService
    implements StudentNotificationServiceInterface {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Appointment>> fetchUpcomingAppointments(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('studentId', isEqualTo: studentId)
          .where('status', isEqualTo: 'Approved')
          .get();

      return snapshot.docs
          .map((doc) => Appointment.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching appointments: $e');
    }
  }
}
