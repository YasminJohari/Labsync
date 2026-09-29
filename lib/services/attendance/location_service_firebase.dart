import 'package:geolocator/geolocator.dart';
import 'package:labsync/services/attendance/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class LocationServiceImplementation extends LocationServiceAbstract {
  final Map<String, double> labCoordinates = {
    'latitude': 1.56436, // Replace with actual latitude
    'longitude': 103.63783, // Replace with actual longitude
  };
  final double labRadiusInMeters = 500;

  final Map<String, Map<String, double>> classrooms = {
    'CGMTL': {'latitude': 1.56436, 'longitude': 103.63783, 'radius': 500},
    'KDSE': {'latitude': 1.5667, 'longitude': 103.6259, 'radius': 500},
    'KTDI': {'latitude': 1.56508, 'longitude': 103.63583, 'radius': 500},
  };

  @override
  Future<bool> requestLocationPermission() async {
    return true;
  }

  @override
  Future<Position?> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  bool isInsideLab(Position position) {
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      labCoordinates['latitude']!,
      labCoordinates['longitude']!,
    );
    return distance <= labRadiusInMeters;
  }

  @override
  String checkClassroom(Position position) {
    String classroomFound = "Not in any classroom";
    double minDistance = double.infinity;

    classrooms.forEach((classroom, details) {
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        details['latitude']!,
        details['longitude']!,
      );
      if (distance <= details['radius']! && distance < minDistance) {
        minDistance = distance;
        classroomFound = classroom;
      }
    });

    return classroomFound;
  }

  @override
  Future<void> storeLocationInFirebase(String username, String lecturerId,
      String attendanceStatus, String classroom, Position position) async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('students').doc(user.uid).set({
      'name': username,
      'lecturerId': lecturerId,
      'location': {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      },
      'attendanceStatus': attendanceStatus,
      'currentClassroom': classroom,
    });
  }

  @override
  Future<void> storeAttendanceHistory(String username, String lecturerId,
      String classroom, Position position, String attendanceStatus) async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('attendance_history').add({
      'userId': user.uid,
      'username': username,
      'lecturerId': lecturerId,
      'classroom': classroom,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'status': attendanceStatus,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
