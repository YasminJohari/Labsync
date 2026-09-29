import 'package:labsync/models/appointment_model.dart';
import 'package:labsync/models/user_model.dart';

abstract class SearchAppointmentServiceAbstract {
  Future<List<Appointment>> fetchAppointments(String lecturerId);
  Future<List<User>> getUsersByMatricNumber(String matricNumber);
}
