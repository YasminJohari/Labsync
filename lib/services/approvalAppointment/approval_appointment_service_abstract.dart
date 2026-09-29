import 'package:labsync/models/appointment_model.dart';

abstract class ApprovalAppointmentServiceAbstract {
  Future<List<Appointment>> fetchAppointments(String lecturerId);
  Future<void> updateAppointmentStatus(String appointmentId, String status);
}