import 'package:labsync/services/studentAppointment/student_appointment_service_implementation.dart';
import 'package:map_mvvm/view/viewmodel.dart';

class StudentAppointmentViewModel extends Viewmodel { // Extend ViewModel
  final StudentAppointmentService _appointmentService;

  // Store lecturer's schedule for the entire semester
  List<Map<String, dynamic>> lecturerSchedule = [];

  StudentAppointmentViewModel(this._appointmentService);

  // Fetch the lecturer's schedule via the service
  Future<List<Map<String, dynamic>>> fetchLecturerSchedule(String lecturerId) async {
    try {
      // Call update method to handle busy state while fetching
      await update(() async {
        final scheduleData = await _appointmentService.fetchLecturerSchedule(lecturerId);
        lecturerSchedule = scheduleData;
      });
      return lecturerSchedule;
    } catch (e) {
      print("Error fetching lecturer schedule: $e");
      return [];
    }
  }

  // Get available times for a selected day
  List<String> getAvailableTimes(String lecturerId, DateTime selectedDay) {
    final availableTimes = <String>[];

    final selectedDateString =
        "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";

    for (var schedule in lecturerSchedule) {
      if (schedule['date'] == selectedDateString &&
          schedule['status'] != 'Booked') {
        // Exclude "Booked"
        availableTimes.add(schedule['time']);
      }
    }

    return availableTimes;
  }

  Future<void> bookAppointment(String lecturerId, DateTime date, String time) async {
    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    await _appointmentService.updateAppointmentStatus(lecturerId, formattedDate, time, 'Booked');
  }
}
