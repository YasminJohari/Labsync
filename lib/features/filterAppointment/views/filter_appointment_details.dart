import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final Appointment appointment;

  AppointmentDetailsScreen({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student ID: ${appointment.studentId}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Lecturer ID: ${appointment.lecturerId}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Username: ${appointment.username}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('User Role: ${appointment.userRole}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Reason: ${appointment.reason}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Additional Notes: ${appointment.additionalNotes}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Status: ${appointment.status}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Date: ${appointment.date.toLocal()}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Time: ${appointment.time.toLocal()}',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
