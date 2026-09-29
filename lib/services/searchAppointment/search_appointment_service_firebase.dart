import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labsync/models/appointment_model.dart';
import 'package:labsync/models/user_model.dart';
import 'package:labsync/services/searchAppointment/search_appointment_service.dart';

class FirebaseSearchAppointmentService
    implements SearchAppointmentServiceAbstract {
  final FirebaseFirestore firestore;

  FirebaseSearchAppointmentService(this.firestore);

  @override
  Future<List<Appointment>> fetchAppointments(String lecturerId) async {
    try {
      final snapshot = await firestore
          .collection('appointments')
          .where('lecturerId', isEqualTo: lecturerId)
          .get();

      // Use fromJson instead of fromFirestore
      return snapshot.docs
          .map((doc) => Appointment.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Handle error appropriately
      return [];
    }
  }

  Future<List<User>> getUsersByMatricNumber(String matricNumber) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('matricNumber', isEqualTo: matricNumber.trim())
          .get();

      return querySnapshot.docs.map((doc) {
        return User.fromMap(doc.data());
      }).toList();
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }
}
