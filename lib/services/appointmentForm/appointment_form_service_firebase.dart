import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labsync/models/appointment_model.dart';
import 'package:labsync/services/appointmentForm/appointment_form_service.dart';

class AppointmentService implements AppointmentServiceInterface {
  final FirebaseFirestore firestore;

  AppointmentService(this.firestore);

  @override
  Future<void> createAppointment(Appointment appointment) async {
    final data = appointment.toJson();

    // Add default status if userRole is 'Student'
    if (data['userRole'] == 'Student') {
      data['status'] = 'Pending';
    } else {
      data['status'] = 'Approved';
    }

    await firestore.collection('appointments').add(data);
  }
}
