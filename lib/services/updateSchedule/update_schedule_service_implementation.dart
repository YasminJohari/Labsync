import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:labsync/services/updateSchedule/update_schedule_service_abstract.dart';

class LecturerScheduleService implements LecturerScheduleServiceInterface {
  final FirebaseFirestore _firestore;

  LecturerScheduleService(this._firestore);

  @override
  Future<Map<String, List<String>>> fetchSchedule(String lecturerId) async {
    try {
      final docRef = _firestore.collection('lecturers').doc(lecturerId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final scheduleData =
            docSnapshot.data()?['schedule'] as List<dynamic>? ?? [];

        debugPrint(
            'Fetched schedule from Firestore: $scheduleData'); // Log the fetched data

        final Map<String, List<String>> schedule = {};

        for (var slot in scheduleData) {
          final date = slot['date'];
          final time = slot['time'];

          if (date != null && time != null) {
            if (schedule.containsKey(date)) {
              schedule[date]!.add(time);
            } else {
              schedule[date] = [time];
            }
          }
        }

        debugPrint(
            'Formatted schedule: $schedule'); // Log the formatted schedule map
        return schedule;
      } else {
        debugPrint('No schedule found for lecturer: $lecturerId');
      }
    } catch (e) {
      debugPrint('Error fetching schedule: $e');
    }
    return {}; // Return empty map if no data or error occurs
  }

  @override
  Future<void> addTimeSlot(String lecturerId, String date, String time) async {
    try {
      final docRef = _firestore.collection('lecturers').doc(lecturerId);
      await docRef.set({
        'schedule': FieldValue.arrayUnion([
          {'date': date, 'time': time, 'status': 'available'}
        ])
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Error adding time slot: $e");
    }
  }

  @override
  Future<void> removeTimeSlot(
      String lecturerId, String date, String time) async {
    try {
      final docRef = _firestore.collection('lecturers').doc(lecturerId);

      // Get the current schedule
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final List<dynamic> schedule = data?['schedule'] ?? [];

        // Filter out slots with matching date and time
        final updatedSchedule = schedule
            .where((slot) => slot['date'] != date || slot['time'] != time)
            .toList();

        // Update the schedule
        await docRef.update({'schedule': updatedSchedule});
      }
    } catch (e) {
      throw Exception("Error removing time slot: $e");
    }
  }
}
