import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_schedule_service_abstract.dart';
import 'package:intl/intl.dart';

class StudentScheduleServiceImpl implements StudentScheduleServiceAbstract {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Map<String, dynamic>>> fetchSchedules(String studentId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('studentId', isEqualTo: studentId)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception("No schedules found for this student.");
      }

      List<Map<String, dynamic>> schedules = snapshot.docs.map((doc) {
        // Extract data and format timestamps
        DateTime date;
        if (doc['date'] is Timestamp) {
          date = (doc['date'] as Timestamp).toDate(); // Convert from Timestamp
        } else if (doc['date'] is String) {
          date = DateTime.parse(doc['date']); // Parse from String
        } else {
          date = DateTime.now(); // Default fallback
        }

        // Handle 'time' field
        DateTime time;
        if (doc['time'] is Timestamp) {
          time = (doc['time'] as Timestamp).toDate(); // Convert from Timestamp
        } else if (doc['time'] is String) {
          time = DateTime.parse(doc['time']); // Parse from String
        } else {
          time = DateTime.now(); // Default fallback
        }

        // Format the timestamps into readable strings
        String formattedDate = DateFormat('d MMMM yyyy').format(date);
        String formattedTime = DateFormat('h:mm a').format(time);

        return {
          'scheduleId': doc.id,
          'date': formattedDate, // Formatted date (e.g., "16 December 2024")
          'timeSlot':
              formattedTime, // Formatted time (e.g., "16 December 2024, 11:30 AM")
          'studentId': doc['studentId'] ?? 'Unknown Student',
          'status': doc['status'] ?? 'Unknown Status',
          'reason': doc['reason'] ?? 'No reason provided',
        };
      }).toList();

      // Sort the schedules by the 'date' field in ascending order
      schedules.sort((a, b) {
        var dateA = DateFormat('d MMMM yyyy').parse(a['date']);
        var dateB = DateFormat('d MMMM yyyy').parse(b['date']);
        return dateA.compareTo(dateB); // Ascending order
      });

      return schedules;
    } catch (e) {
      print("Error fetching schedules: $e");
      throw Exception("Error fetching schedules: $e");
    }
  }
}
