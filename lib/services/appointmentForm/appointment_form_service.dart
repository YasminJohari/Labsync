import 'package:labsync/models/appointment_model.dart';

abstract class AppointmentServiceInterface {
  Future<void> createAppointment(Appointment appointment);
}
