import 'package:labsync/models/appointment_model.dart';

abstract class StudentNotificationServiceInterface {
  Future<List<Appointment>> fetchUpcomingAppointments(String studentId);
}
