import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String studentId;
  final String lecturerId;
  final String username;
  final String userRole;
  final String reason;
  final String additionalNotes;
  String status;
  final DateTime date;
  final DateTime time;

  Appointment({
    required this.id,
    required this.studentId,
    required this.lecturerId,
    required this.username,
    required this.userRole,
    required this.reason,
    required this.additionalNotes,
    required this.status,
    required this.date,
    required this.time,
  });

  // Convert Appointment object to a JSON map for Firestore or memory storage
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include id in the JSON map
      'studentId': studentId,
      'lecturerId': lecturerId,
      'username': username,
      'userRole': userRole,
      'reason': reason,
      'additionalNotes': additionalNotes,
      'status': status,
      'date': date.toIso8601String(),
      'time': time.toIso8601String(),
    };
  }

  // Create an Appointment object from a JSON map (e.g., from Firestore)
  factory Appointment.fromJson(Map<String, dynamic> json, String docId) {
    return Appointment(
      id: docId,
      studentId: json['studentId'] ?? '',
      lecturerId: json['lecturerId'] ?? '',
      username: json['username'] ?? '',
      userRole: json['userRole'] ?? '',
      reason: json['reason'] ?? '',
      additionalNotes: json['additionalNotes'] ?? 'No notes provided',
      status: json['status'] ?? '',
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate() // If Timestamp
          : DateTime.parse(json['date']), // If String
      time: json['time'] is Timestamp
          ? (json['time'] as Timestamp).toDate() // If Timestamp
          : DateTime.parse(json['time']), // If String
    );
  }
}
