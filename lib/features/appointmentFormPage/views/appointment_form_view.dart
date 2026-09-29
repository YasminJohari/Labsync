import 'package:flutter/material.dart';
import 'package:map_mvvm/view/view.dart';
import 'package:labsync/features/appointmentFormPage/viewmodels/appointment_form_viewmodel.dart';

class AppointmentFormView extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime selectedTime;
  final String username;
  final String studentId;
  final String lecturerId;
  final String userRole;
  final String id;
  final String status;

  const AppointmentFormView({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.username,
    required this.studentId,
    required this.lecturerId,
    required this.userRole,
    required this.id,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return ViewWrapper<AppointmentFormViewModel>(
      builder: (context, viewModel) {
        final formKey = GlobalKey<FormState>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Appointment Details'),
            backgroundColor: const Color.fromARGB(255, 99, 29, 59),
            elevation: 2.0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Appointment Details Card
                    Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Appointment Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Date: ${selectedDate.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Time: ${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Reason for Appointment Field
                    const Text(
                      'Reason for Appointment',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: viewModel.reasonController,
                      decoration: InputDecoration(
                        hintText: 'Enter reason...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a reason';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Additional Notes Field
                    const Text(
                      'Additional Notes (Optional)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: viewModel.notesController,
                      decoration: InputDecoration(
                        hintText: 'Add any extra information...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          viewModel.submitForm(
                            context: context,
                            studentId: studentId,
                            lecturerId: lecturerId,
                            username: username,
                            selectedDate: selectedDate,
                            selectedTime: selectedTime,
                            userRole: userRole,
                            id: id,
                            status: status,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 99, 29, 59),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Submit Appointment',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
