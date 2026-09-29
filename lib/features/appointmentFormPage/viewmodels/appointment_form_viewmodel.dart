import 'package:flutter/material.dart';
import 'package:map_mvvm/view/viewmodel.dart';
import 'package:labsync/configs/services_locators.dart';
import 'package:labsync/models/appointment_model.dart';
import 'package:labsync/services/appointmentForm/appointment_form_service.dart';

class AppointmentFormViewModel extends Viewmodel {
  final AppointmentServiceInterface _appointmentService =
      serviceLocator<AppointmentServiceInterface>();

  final TextEditingController reasonController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  Future<void> submitForm({
    required BuildContext context,
    required String studentId,
    required String lecturerId,
    required DateTime selectedDate,
    required DateTime selectedTime,
    required String username,
    required String userRole,
    required String id,
    required String status,
    
  }) async {
    final appointment = Appointment(
      studentId: studentId,
      lecturerId: lecturerId,
      username: username,
      userRole: userRole,
      reason: reasonController.text,
      additionalNotes: notesController.text,
      date: selectedDate,
      time: selectedTime, 
      id: id, 
      status: status,
    );

    try {
      await _appointmentService.createAppointment(appointment);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment submitted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit appointment')),
      );
    }
  }

  @override
  void dispose() {
    reasonController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
