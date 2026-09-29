import 'package:flutter/material.dart';
import 'package:labsync/configs/services_locators.dart';
import 'package:labsync/features/StudentActivityHistory/activity_view.dart';
import 'package:labsync/features/studentAppointment/viewmodels/student_appointment_viewmodel.dart';
import 'package:labsync/features/studentNotification/student_notification_view.dart';
import 'package:labsync/features/studentNotification/student_notification_viewmodel.dart';
import 'package:labsync/services/studentNotification/student_notification_service_impl.dart';
import 'package:provider/provider.dart';
import 'package:labsync/features/attendance/views/update_att_view.dart';
import 'package:labsync/features/profile/views/profile_view.dart';
import 'package:labsync/features/studentAppointment/views/student_appointment_view.dart';
import 'package:labsync/features/studentSchedule/views/student_schedule_view.dart';
import 'package:labsync/features/workProgress/views/student_work_progress_view.dart';
import 'package:labsync/features/workProgress/viewmodels/student_work_progress_viewmodel.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final int currentIndex; // To determine the active tab
  final Widget body; // Main content for the page
  final String username; // Logged-in user's username
  final String lecturerId; // Lecturer's ID linked to the student

  const ScaffoldWithNavBar({
    super.key,
    required this.currentIndex,
    required this.body,
    required this.username,
    required this.lecturerId,
    required String studentId,
    required String userId,
  });

  void _onTabTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StudentDashboardView(
            username: username,
            lecturerId: lecturerId,
          ),
        ),
      );
    } else if (index == 1) {
      final studentAppointmentViewModel =
          serviceLocator<StudentAppointmentViewModel>();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentAppointmentView(
            username: username,
            lecturerId: lecturerId,
            studentId: username,
            viewModel: studentAppointmentViewModel, // Pass the ViewModel
          ),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: username),
        ),
      );
    }
  }

  void _onDrawerItemTapped(BuildContext context, String route) {
    if (route == 'schedule') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentScheduleView(studentId: username),
        ),
      );
    } else if (route == 'work_progress') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => StudentWorkProgressViewModel(studentId: username),
            child: StudentWorkProgressView(
              studentId: username,
              lecturerId: lecturerId,
            ),
          ),
        ),
      );
    } else if (route == 'activity_history') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentActivityHistoryView(studentId: username),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentNotificationViewModel(StudentNotificationService())
        ..fetchNotifications(username),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('LabSync'),
              backgroundColor: const Color.fromARGB(
                  255, 99, 29, 59), // Customize app bar color

// add a notification icon that can go to a studentNotificationView only by the studentId
              actions: [
                Consumer<StudentNotificationViewModel>(
                  builder: (context, viewModel, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentNotificationView(
                                    studentId: username),
                              ),
                            );
                          },
                        ),
                        if (viewModel.hasNotifications)
                          Positioned(
                            right: 11,
                            top: 11,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
            body: body, // The main content
            drawer: Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 99, 29, 59)),
                    child: Text(
                      'Hello, $username!',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Student Schedule'),
                    onTap: () => _onDrawerItemTapped(context, 'schedule'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.assignment),
                    title: const Text('Work Progress'),
                    onTap: () => _onDrawerItemTapped(context, 'work_progress'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Activity History'),
                    onTap: () =>
                        _onDrawerItemTapped(context, 'activity_history'),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => _onTabTapped(context, index),
              selectedItemColor: Colors.black, // Color for the selected icon
              unselectedItemColor: Colors.grey, // Color for unselected icons
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.schedule),
                  label: 'Appointments',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
