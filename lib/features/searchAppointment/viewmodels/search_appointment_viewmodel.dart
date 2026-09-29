import 'package:flutter/material.dart';
import 'package:labsync/models/appointment_model.dart';
import 'package:map_mvvm/view/viewmodel.dart';
import 'package:labsync/configs/services_locators.dart';
import 'package:labsync/services/searchAppointment/search_appointment_service.dart';

class AppointmentSearchViewModel extends Viewmodel {
  final SearchAppointmentServiceAbstract _service =
      serviceLocator<SearchAppointmentServiceAbstract>();

  List<Appointment> _appointments = [];
  List<Appointment> _searchResults = [];
  bool _isLoading = false;
  DateTime? _selectedDate;

  // Getters
  List<Appointment> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  DateTime? get selectedDate => _selectedDate;

  // Fetch appointments by lecturer ID
  Future<void> fetchAppointments(String lecturerId) async {
    if (_isLoading || _appointments.isNotEmpty)
      return; // Prevent repeated fetches
    _isLoading = true;
    notifyListeners();

    try {
      _appointments = await _service.fetchAppointments(lecturerId);
      _searchResults = _appointments; // Populate initial results
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
      _appointments = [];
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter appointments by matric number and date
  void filterAppointments(String matricNumber, DateTime? date) async {
    debugPrint(
        'Filtering appointments with matric: $matricNumber, date: $date');

    // Reset results before filtering
    _searchResults = [];
    notifyListeners();

    // Fetch users by matric number if provided
    final users = matricNumber.isEmpty
        ? []
        : await _service.getUsersByMatricNumber(matricNumber);

    // Extract matching student IDs
    final matchingStudentIds = matricNumber.isEmpty
        ? null
        : users.map((user) => user.username).toSet();

    // Filter appointments
    _searchResults = _appointments.where((appointment) {
      final DateTime appointmentDate = appointment.date;

      // Check matric number condition
      final matchesMatric = matchingStudentIds == null ||
          matchingStudentIds.contains(appointment.studentId);

      // Check date condition
      final matchesDate = date == null ||
          (appointmentDate.year == date.year &&
              appointmentDate.month == date.month &&
              appointmentDate.day == date.day);

      // Return true only if both conditions match
      return matchesMatric && matchesDate;
    }).toList();

    // Notify listeners after filtering
    notifyListeners();

    // Debug output for troubleshooting
    if (_searchResults.isEmpty) {
      debugPrint('No matching appointments found.');
    } else {
      debugPrint(
          'Filtered appointments count: ${_searchResults.length}, content: $_searchResults');
    }
  }

  // Clear filters
  void clearFilters() {
    _selectedDate = null;
    _searchResults = List.from(_appointments);
    notifyListeners();
  }

  // Search appointments by any field including matric number
  void searchAppointments(String query) {
    if (query.isEmpty) {
      _searchResults = _appointments;
    } else {
      final lowerQuery = query.toLowerCase();
      _searchResults = _appointments.where((appointment) {
        final combinedData =
            '${appointment.id} ${appointment.studentId} ${appointment.lecturerId} ${appointment.date} ${appointment.time} ${appointment.status} ${appointment.reason}';
        return combinedData.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }

  // Set date filter
  void setDateFilter(DateTime date) {
    _selectedDate = date;
    filterAppointments("", _selectedDate);
  }
}
