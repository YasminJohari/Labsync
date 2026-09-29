import 'package:labsync/configs/services_locators.dart';
import 'package:labsync/services/StudentActivityHistory/activity_abstract.dart';
import 'package:map_mvvm/view/viewmodel.dart';

class StudentActivityHistoryViewModel extends Viewmodel {
  final _service = serviceLocator<StudentActivityHistoryServiceAbstract>();

  List<Map<String, dynamic>> attendanceRecord = [];
  List<Map<String, dynamic>> appointments = [];
  List<Map<String, dynamic>> workProgress = [];

  bool _isLoading = false; // Define the loading flag
  bool get isLoading => _isLoading; // Getter for isLoading

  bool _isDisposed = false;

  // Initialize fetching data
  Future<void> initialize(String studentId) async {
    await Future.wait([
      fetchAttendanceRecord(studentId),
      fetchAppointments(studentId),
      fetchWorkProgress(studentId),
    ]);
  }

  // Fetch Attendance Record
  Future<void> fetchAttendanceRecord(String studentId) async {
    if (_isDisposed) return;

    _isLoading = true;
    notifyListeners();

    try {
      final rawAttendanceRecords =
          await _service.fetchAttendanceHistory(studentId);
      attendanceRecord = rawAttendanceRecords;

      if (attendanceRecord.isEmpty) {}
    } catch (e) {
      attendanceRecord = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch Appointments
  Future<void> fetchAppointments(String studentId) async {
    if (_isDisposed) return;

    _isLoading = true;
    notifyListeners();

    try {
      appointments = await _service.fetchAppointments(studentId);
      if (appointments.isEmpty) {}
      // ignore: empty_catches
    } catch (e) {}

    _isLoading = false;
    notifyListeners();
  }

  // Fetch Work Progress
  Future<void> fetchWorkProgress(String studentId) async {
    if (_isDisposed) return;

    _isLoading = true;
    notifyListeners();

    try {
      workProgress = await _service.fetchWorkProgress(studentId);
      if (workProgress.isEmpty) {}
      // ignore: empty_catches
    } catch (e) {}

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
