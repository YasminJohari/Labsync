import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labsync/models/appointment_model.dart';
import 'package:labsync/services/approvalAppointment/approval_appointment_service_abstract.dart';

class ApprovalAppointmentServiceImpl
    implements ApprovalAppointmentServiceAbstract {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Appointment>> fetchAppointments(String lecturerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('lecturerId', isEqualTo: lecturerId)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              Appointment.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching appointments: $e');
    }
  }

  @override
  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Error updating appointment status: $e');
    }
  }
}