import 'package:flutter/material.dart';
import 'package:labsync/features/studentAppointment/viewmodels/student_appointment_viewmodel.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:labsync/features/appointmentFormPage/views/appointment_form_view.dart';

class StudentAppointmentView extends StatelessWidget {
  final String studentId;
  final String lecturerId;
  final String username;
  final StudentAppointmentViewModel viewModel;

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final ValueNotifier<DateTime> _refreshTrigger = ValueNotifier(DateTime.now());

  StudentAppointmentView({
    super.key,
    required this.studentId,
    required this.lecturerId,
    required this.username,
    required this.viewModel,
  });

  void _showAvailableTimes(
    BuildContext context,
    List<String> times,
    DateTime? selectedDay,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Available Times',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: times.map((time) {
            return ListTile(
              title: Text(time, style: const TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context); // Close the dialog
                final selectedDate = selectedDay ?? DateTime.now();
                final timeParts = time.split(':');
                final selectedTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  int.parse(timeParts[0]),
                  int.parse(timeParts[1]),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentFormView(
                      selectedDate: selectedDate,
                      selectedTime: selectedTime,
                      username: username,
                      studentId: studentId,
                      lecturerId: lecturerId,
                      userRole: 'Student',
                      id: '',
                      status: 'Pending',
                    ),
                  ),
                ).then((_) async {
                  try {
                    await viewModel.bookAppointment(
                        lecturerId, selectedDate, time);
                    scaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(
                        content: Text('Appointment booked successfully!',
                            style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _refreshTrigger.value = DateTime.now();
                  } catch (e) {
                    scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text('Error booking appointment: $e',
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldMessengerKey,
      appBar: AppBar(
        title: const Text('Book Appointment',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 99, 29, 59),
        elevation: 3,
      ),
      body: ValueListenableBuilder(
        valueListenable: _refreshTrigger,
        builder: (_, __, ___) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: viewModel.fetchLecturerSchedule(lecturerId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red)),
                );
              }

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      elevation: 3,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose a Date',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Select a date to view available appointment times with your lecturer.',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TableCalendar(
                        firstDay: DateTime(2024),
                        lastDay: DateTime(2026),
                        focusedDay: DateTime.now(),
                        calendarFormat: CalendarFormat.month,
                        selectedDayPredicate: (day) => false,
                        onDaySelected: (selectedDay, focusedDay) {
                          final availableTimes = viewModel.getAvailableTimes(lecturerId, selectedDay);
                          if (availableTimes.isNotEmpty) {
                            _showAvailableTimes(context, availableTimes,
                                selectedDay);
                          } else {
                            scaffoldMessengerKey.currentState?.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No available times for this date',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                         eventLoader: (day) {
                          return viewModel
                              .getAvailableTimes(lecturerId, day)
                              .map((time) => {'time': time})
                              .toList();
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.blue.shade300,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: const BoxDecoration(
                            color: Colors.purple,
                            shape: BoxShape.circle,
                          ),
                          outsideDaysVisible: false,
                        ),
                        headerStyle: const HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}