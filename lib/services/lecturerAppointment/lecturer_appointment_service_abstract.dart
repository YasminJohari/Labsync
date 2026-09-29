abstract class LecturerAppointmentServiceAbstract {
  Future<List<Map<String, dynamic>>> getStudentsForLecturer(String lecturerId);
  Future<void> deleteStudent(String studentId);
}
