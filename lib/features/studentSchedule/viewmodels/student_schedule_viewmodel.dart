import 'package:labsync/configs/services_locators.dart';
import 'package:map_mvvm/view/viewmodel.dart';
import 'package:labsync/services/studentSchedule/student_schedule_service_abstract.dart';

class StudentScheduleViewModel extends Viewmodel {
  final StudentScheduleServiceAbstract _service =
      serviceLocator<StudentScheduleServiceAbstract>();

  // Private variables
  List<Map<String, dynamic>> _lecturerSchedules = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get lecturerSchedules => _lecturerSchedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// **Set loading state**
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners(); // Notify view about the update
  }

  /// **Set error message**
  void setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners(); // Notify view about the error
  }

  /// **Fetch student schedules**
  Future<void> fetchSchedules(String studentId) async {
    try {
      setLoading(true); // Set loading to true
      _lecturerSchedules = await _service.fetchSchedules(studentId);
      setError(null); // Clear any previous errors
    } catch (e) {
      setError("Error fetching schedules: $e"); // Handle errors
    } finally {
      setLoading(false); // Set loading to false
    }
  }
}
