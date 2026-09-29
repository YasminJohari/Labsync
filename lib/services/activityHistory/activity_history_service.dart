import 'package:labsync/models/appointment_model.dart';
import 'package:labsync/models/work_progress.dart';

abstract class ActivityHistoryServiceInterface {
  Future<List<Appointment>> getLecturerActivities(String lecturerId);
  Future<List<WorkProgress>> getWorkProgressWithComments(String lecturerId);
}
