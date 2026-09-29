import 'package:flutter/material.dart';
import 'package:labsync/features/activityHistory/activity_history_view.dart';
import 'package:labsync/features/activityHistory/activity_history_viewmodel.dart';
import 'package:labsync/features/approvalAppointment/views/approval_appointment_view.dart';
import 'package:labsync/features/lecturerDashboard/viewmodels/lecturer_dashboard_viewmodel.dart';
import 'package:labsync/features/lecturerSchedule/viewmodels/lecturer_schedule_viewmodel.dart';
import 'package:labsync/features/lecturerSchedule/views/lecturer_schedule_view.dart'; // Make sure to import the LecturerScheduleView
import 'package:labsync/features/searchAppointment/viewmodels/search_appointment_viewmodel.dart';
import 'package:labsync/features/searchAppointment/views/search_appointment_view.dart';
import 'package:labsync/features/updateSchedule/views/update_schedule_view.dart';
import 'package:labsync/features/workProgress/viewmodels/lecturer_work_progress_viewmodel.dart';
import 'package:labsync/features/workProgress/views/lecturer_work_progress_view.dart';
import 'package:labsync/features/notificationRequest/notification_request_view.dart';
import 'package:labsync/features/notificationRequest/notification_request_viewmodel.dart';
import 'package:labsync/features/labPresence/view/lab_presence_view.dart';
import 'package:labsync/features/profile/views/profile_view.dart';
import 'package:labsync/features/lecturerAppointment/views/lecturer_appointment_view.dart';
import 'package:provider/provider.dart';

class LecturerDashboardView extends StatefulWidget {
  final String lecturerId;
  final String username;

  const LecturerDashboardView(
      {super.key, required this.lecturerId, required this.username});

  @override
  _LecturerDashboardViewState createState() => _LecturerDashboardViewState();
}

class _LecturerDashboardViewState extends State<LecturerDashboardView> {
  late final LecturerDashboardViewModel _viewModel;
  late final LecturerScheduleViewModel1 _scheduleViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LecturerDashboardViewModel(
        lecturerId: widget.lecturerId, username: widget.username);
    _scheduleViewModel =
        LecturerScheduleViewModel1(lecturerId: widget.lecturerId);
    _scheduleViewModel.fetchScheduleWithRequests(widget.lecturerId);
  }

  @override
  void dispose() {
    _scheduleViewModel.dispose();
    super.dispose();
  }

  void _onDrawerItemTapped(BuildContext context, String route) {
    if (route == 'approve_appointments') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApprovalAppointmentView(
            lecturerId: widget.lecturerId,
          ),
        ),
      );
    } else if (route == 'view_schedule') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: _scheduleViewModel, // Use the existing provider
            child: LecturerScheduleView(lecturerId: widget.lecturerId),
          ),
        ),
      );
    } else if (route == 'lab_presence') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LabAttendanceView(
            lecturerId: widget.lecturerId,
          ),
        ),
      );
    } else if (route == 'appointment_info') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) => AppointmentSearchViewModel(),
            child: AppointmentSearchView(lecturerId: widget.lecturerId),
          ),
        ),
      );
    } else if (route == 'work_progress') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) =>
                LecturerWorkProgressViewModel(lecturerId: widget.lecturerId),
            child: LecturerWorkProgressView(
              lecturerId: widget.lecturerId,
            ),
          ),
        ),
      );
    } else if (route == 'activity_history') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => ActivityHistoryViewModel(),
            child: ActivityHistoryView(
              lecturerId: widget.lecturerId,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lecturer Dashboard'),
          backgroundColor: const Color.fromARGB(255, 99, 29, 59),
          actions: [
            Consumer<NotificationViewModel>(
                builder: (context, notificationViewModel, _) {
              final hasNewNotifications =
                  notificationViewModel.appointmentRequests.isNotEmpty;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationView(
                            lecturerId: widget.lecturerId,
                          ),
                        ),
                      );
                    },
                  ),
                  if (hasNewNotifications)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration:
                    const BoxDecoration(color: Color.fromARGB(255, 99, 29, 59)),
                child: Text(
                  'Hello, ${widget.username}!',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.check_box),
                title: const Text('Approve Appointments'),
                onTap: () =>
                    _onDrawerItemTapped(context, 'approve_appointments'),
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('View Schedule'),
                onTap: () => _onDrawerItemTapped(context, 'view_schedule'),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Lab Presence'),
                onTap: () => _onDrawerItemTapped(context, 'lab_presence'),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Appointment Info'),
                onTap: () => _onDrawerItemTapped(context, 'appointment_info'),
              ),
              ListTile(
                leading: const Icon(Icons.work),
                title: const Text('Work Progress'),
                onTap: () => _onDrawerItemTapped(context, 'work_progress'),
              ),
              ListTile(
                leading: const Icon(Icons.history_edu),
                title: const Text('Activity History'),
                onTap: () => _onDrawerItemTapped(context, 'activity_history'),
              ),
            ],
          ),
        ),
        body: _viewModel.selectedIndex == 0
            ? LecturerAppointmentView(lecturerId: widget.lecturerId)
            : _viewModel.selectedIndex == 1
                ? LecturerScheduleUpdateView(
                    lecturerId: widget.lecturerId,
                  )
                : _viewModel.selectedIndex == 2
                    ? ProfilePage(userId: widget.username)
                    : _viewModel.pages[_viewModel.selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _viewModel.selectedIndex,
          onTap: (index) => setState(() {
            _viewModel.onItemTapped(index); // Change selected page
          }),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Set Appointment',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.update),
              label: 'Update Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Profile',
            ),
          ],
          selectedItemColor: const Color.fromARGB(255, 99, 29, 59),
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }
}
