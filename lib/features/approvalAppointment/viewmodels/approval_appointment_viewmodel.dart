import 'package:flutter/material.dart';
import 'package:labsync/models/appointment_model.dart';
import 'package:labsync/services/approvalAppointment/approval_appointment_service_abstract.dart';

class ApprovalAppointmentViewmodel extends ChangeNotifier {
  final ApprovalAppointmentServiceAbstract _service;

  ApprovalAppointmentViewmodel(this._service);

  // Data and state variables
  List<Appointment> _appointments = [];
  bool _isLoading = false;

  // Getters for grouped appointments
  List<Appointment> get pendingAppointments =>
      _appointments.where((a) => a.status == 'Pending').toList();

  List<Appointment> get approvedAppointments =>
      _appointments.where((a) => a.status == 'Approved').toList();

  List<Appointment> get rejectedAppointments =>
      _appointments.where((a) => a.status == 'Rejected').toList();

  bool get isLoading => _isLoading;

  /// Fetch Appointments - Ensures data is only fetched when required
  Future<void> fetchAppointments(String lecturerId) async {
    if (_appointments.isNotEmpty) {
      return; // Prevent duplicate calls if data already exists
    }

    _setLoading(true); // Optimized loading state management

    try {
      // Fetch appointments once
      final fetchedAppointments = await _service.fetchAppointments(lecturerId);
      _appointments = fetchedAppointments;
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    } finally {
      _setLoading(false); // Stop loading
    }
  }

  /// Update Appointment Status - Optimized without full refresh
  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    try {
      // Update the status in Firestore
      await _service.updateAppointmentStatus(appointmentId, status);

      // Find the index of the appointment to update
      final appointments =
          _appointments.firstWhere((a) => a.id == appointmentId);
      appointments.status = status;
      notifyListeners();
    } catch (e) {
      throw Exception('Error updating appointment status: $e');
    }
  }

  /// Private method to handle loading state changes
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners(); // Notify only when the state actually changes
    }
  }
}