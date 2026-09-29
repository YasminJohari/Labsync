import 'package:labsync/models/appointment_model.dart';

abstract class NotificationServiceInterface {
  Future<List<Appointment>> fetchPendingAppointments(String lecturerId);
  Future<List<Appointment>> fetchRecommendedAppointments(String lecturerId);
}
