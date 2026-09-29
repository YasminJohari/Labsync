import 'package:flutter/material.dart';
import 'package:labsync/features/activityHistory/activity_history_view.dart';
import 'package:labsync/features/approvalAppointment/viewmodels/approval_appointment_viewmodel.dart';
import 'package:labsync/features/approvalAppointment/views/approval_appointment_view.dart';
import 'package:labsync/features/lecturerAppointment/views/lecturer_appointment_view.dart';
import 'package:labsync/features/searchAppointment/views/search_appointment_view.dart';
import 'package:labsync/features/searchAppointment/viewmodels/search_appointment_viewmodel.dart';
import 'package:labsync/features/updateSchedule/views/update_schedule_view.dart';
import 'package:labsync/configs/services_locators.dart';
import 'package:labsync/features/lecturerSchedule/views/lecturer_schedule_view.dart';
import 'package:labsync/features/labPresence/view/lab_presence_view.dart';
import 'package:labsync/features/workProgress/views/lecturer_work_progress_view.dart';
import 'package:labsync/services/approvalAppointment/approval_appointment_service_abstract.dart';
import 'package:labsync/features/profile/views/profile_view.dart';
import 'package:provider/provider.dart';

class LecturerDashboardViewModel {
  int selectedIndex = 0;
  final String lecturerId;
  final String username;

  // Constructor to initialize the lecturerId
  LecturerDashboardViewModel(
      {required this.lecturerId, required this.username});

  // Define pages with providers
  late final List<Widget> pages = [
    LecturerAppointmentView(lecturerId: lecturerId), // Set Appointment page

    // Approve Appointments Page
    ChangeNotifierProvider(
      create: (context) => ApprovalAppointmentViewmodel(
        serviceLocator<ApprovalAppointmentServiceAbstract>(),
      ),
      child: ApprovalAppointmentView(lecturerId: lecturerId),
    ),

    // Update Schedule Page
    LecturerScheduleUpdateView(
      lecturerId: lecturerId,
    ),

    // View Schedule Page
    LecturerScheduleView(lecturerId: lecturerId),

    // Lab Presence Page
    LabAttendanceView(
      lecturerId: lecturerId,
    ),

    // Appointment Info Page (To be defined)
    ChangeNotifierProvider(
      create: (context) => AppointmentSearchViewModel(),
      child: AppointmentSearchView(lecturerId: lecturerId),
    ),

    // Work Progress Page
    LecturerWorkProgressView(
      lecturerId: lecturerId,
    ),

    // Profile Page
    ProfilePage(userId: username),

    ActivityHistoryView(
      lecturerId: lecturerId,
    ),
  ];

  // Ensures the selected index is within bounds
  void onItemTapped(int index) {
    if (index >= 0 && index < pages.length) {
      selectedIndex = index;
    } else {
      print('Index out of range: $index');
    }
  }
}
