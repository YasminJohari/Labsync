import 'package:geolocator/geolocator.dart';

abstract class LocationServiceAbstract {
  Future<bool> requestLocationPermission();
  Future<Position?> getCurrentPosition();
  bool isInsideLab(Position position);
  String checkClassroom(Position position);
  Future<void> storeLocationInFirebase(String username, String lecturerId,
      String attendanceStatus, String classroom, Position position);
  Future<void> storeAttendanceHistory(String username, String lecturerId,
      String classroom, Position position, String attendanceStatus);
}