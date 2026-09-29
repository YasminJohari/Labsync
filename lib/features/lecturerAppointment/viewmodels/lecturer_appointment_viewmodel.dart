import 'package:labsync/configs/services_locators.dart';
import 'package:labsync/services/lecturerAppointment/lecturer_appointment_service_abstract.dart';
import 'package:map_mvvm/view/viewmodel.dart';

class LecturerAppointmentViewModel extends Viewmodel {
  String? lecturerId;
  String errorMessage = '';
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];

  @override
  void init() {
    super.init();
    if (lecturerId != null) {
      fetchStudents();
    }
  }

  void setLecturerId(String id) {
    lecturerId = id;
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    errorMessage = '';

    if (lecturerId == null) {
      errorMessage = 'Lecturer ID is not set.';
      return;
    }

    await update(() async {
      try {
        final lecturerAppointmentService =
            serviceLocator<LecturerAppointmentServiceAbstract>();
        students =
            await lecturerAppointmentService.getStudentsForLecturer(lecturerId!);
        filteredStudents = List.from(students);
      } catch (e) {
        errorMessage = 'Error fetching students: $e';
      }
    });
  }

  Future<void> deleteStudent(String studentId) async {
    await update(() async {
      try {
        final lecturerAppointmentService =
            serviceLocator<LecturerAppointmentServiceAbstract>();
        await lecturerAppointmentService.deleteStudent(studentId);

        // Remove the student from the local list
        students.removeWhere((student) => student['username'] == studentId);
        filteredStudents.removeWhere((student) => student['username'] == studentId);
      } catch (e) {
        errorMessage = 'Error deleting student: $e';
      }
    });
  }
}
