import 'package:cloud_firestore/cloud_firestore.dart';

class WorkProgress {
  final String studentId;
  final String lecturerId;
  final String progressTitle;
  final String progressDescription;
  final DateTime submissionDate;
  final String workStatus;
  final List<String> comments;
  final String? fileUrl;

  WorkProgress({
    required this.studentId,
    required this.lecturerId,
    required this.progressTitle,
    required this.progressDescription,
    required this.submissionDate,
    this.workStatus = 'submitted',
    this.comments = const [],
    this.fileUrl,
  });

  factory WorkProgress.fromFirestore(Map<String, dynamic> data) {
    return WorkProgress(
      studentId: data['studentId'],
      lecturerId: data['lecturerId'],
      progressTitle: data['progressTitle'],
      progressDescription: data['progressDescription'],
      submissionDate: (data['submissionDate'] as Timestamp).toDate(),
      workStatus: data['status'] ?? 'submitted',
      comments: List<String>.from(
          data['comments'] is List ? data['comments'] : [data['comments']]),
      fileUrl: data['fileUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'lecturerId': lecturerId,
      'progressTitle': progressTitle,
      'progressDescription': progressDescription,
      'submissionDate': submissionDate,
      'status': workStatus,
      'comments': comments,
      'fileUrl': fileUrl,
    };
  }
}
