import 'package:labsync/configs/services_locators.dart';
import 'package:labsync/services/lecturerSchedule/lecturer_schedule_abstract.dart';
import 'package:map_mvvm/view/viewmodel.dart';

class LecturerScheduleViewModel1 extends Viewmodel {
  final LecturerScheduleServiceAbstract _scheduleService =
      serviceLocator<LecturerScheduleServiceAbstract>();

  final String lecturerId;

  LecturerScheduleViewModel1({required this.lecturerId});

  List<Map<String, dynamic>> _scheduleWithRequests = [];
  bool _isLoading = true;
  bool _disposed = false; // Local flag to track disposal status
  bool isInitialized = false;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get scheduleWithRequests => _scheduleWithRequests;

  @override
  void init() {
    fetchScheduleWithRequests(lecturerId); // Fetch data on initialization
  }

  Future<void> fetchScheduleWithRequests(String lecturerId) async {
    if (_disposed) return; // Ensure no operation if disposed

    try {
      _isLoading = true;
      notifyListeners();

      _scheduleWithRequests =
          await _scheduleService.fetchScheduleWithRequests(lecturerId);

      isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
      print("Error fetching schedule: $e");
    }
  }

  Future<void> cancelAppointment(String appointmentId, String dateStr,
      String timeStr, String lecturerId) async {
    if (_disposed) return; // Ensure no operation if disposed

    try {
      await _scheduleService.cancelAppointment(appointmentId);

      await _scheduleService.updateLecturerStatusToAvailable(
        lecturerId,
        dateStr,
        timeStr,
      );

      _scheduleWithRequests.removeWhere((item) => item["id"] == appointmentId);

      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      if (!_disposed) {
        print("Error cancelling appointment: $e");
      }
    }
  }
}
