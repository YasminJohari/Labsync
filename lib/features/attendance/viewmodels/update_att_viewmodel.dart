import 'package:labsync/services/attendance/location_service.dart';
import 'package:map_mvvm/view/viewmodel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:labsync/configs/services_locators.dart';

class StudentDashboardViewModel extends Viewmodel {
  final LocationServiceAbstract _locationService =
      serviceLocator<LocationServiceAbstract>();

  String attendanceStatus = "Checking location...";
  bool isInsideLab = false;
  String currentClassroom = "Not in any classroom";

  Future<void> checkLabLocation(String username, String lecturerId) async {
    Position? position = await _locationService.getCurrentPosition();

    if (position == null) {
      attendanceStatus = "Unable to retrieve location.";
      notifyListeners();
      return;
    }

    isInsideLab = _locationService.isInsideLab(position);
    if (isInsideLab) {
      attendanceStatus = "You are inside the lab building.";
      currentClassroom = _locationService.checkClassroom(position);

      await _locationService.storeLocationInFirebase(
        username,
        lecturerId,
        attendanceStatus,
        currentClassroom,
        position,
      );
    } else {
      attendanceStatus = "You are not inside the lab building.";
      currentClassroom = "Not in any classroom";
    }
    notifyListeners();
  }
}