import 'package:labsync/models/appointment_model.dart';
import 'package:labsync/services/appointmentForm/appointment_form_service.dart';

class AppointmentMemoryService implements AppointmentServiceInterface {
  final List<Map<String, dynamic>> _appointments = [];

  @override
  Future<void> createAppointment(Appointment appointment) async {
    _appointments.add(appointment.toJson());
  }

  // For testing, return all stored appointments
  List<Appointment> getAppointments() {
    return _appointments.map((map) {
      // Extract ID from the map
      final id = map['id'] ?? '';
      return Appointment.fromJson(map, id); // Pass both arguments
    }).toList();
  }
}
