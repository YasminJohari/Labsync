import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/appointment_model.dart';
// import 'package:labsync/features/searchAppointment/viewmodels/search_appointment_viewmodel.dart';

class AppointmentViewModel extends ChangeNotifier {
  List<Appointment> _appointments = [];
  List<Appointment> _filteredAppointments = [];
  DateTime? _selectedDate;

  List<Appointment> get filteredAppointments => _filteredAppointments;
  DateTime? get selectedDate => _selectedDate;

  // Fetch appointments from Firestore
  Future<void> fetchAppointments() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('appointments').get();
      _appointments = snapshot.docs
          .map((doc) => Appointment.fromJson(doc.data(), doc.id))
          .toList();
      _filteredAppointments =
          List.from(_appointments); // Default to all appointments
      notifyListeners();
    } catch (e) {
      print('Error fetching appointments: $e');
    }
  }

  // Filter appointments by date
  void filterByDate(DateTime date) {
    _selectedDate = date;

    // Strictly filter based on the selected date
    _filteredAppointments = _appointments.where((appointment) {
      return appointment.date.year == date.year &&
          appointment.date.month == date.month &&
          appointment.date.day == date.day;
    }).toList();

    notifyListeners();
  }

  // Utility: Check if two dates are on the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Clear date filter
  void clearDateFilter() {
    _selectedDate = null;
    _filteredAppointments = List.from(_appointments);
    notifyListeners();
  }
}
