import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labsync/models/work_progress.dart';
import 'package:labsync/services/workProgress/work_progress_service.dart';

class WorkProgressViewModel with ChangeNotifier {
  final WorkProgressService workProgressService;
  final FirebaseFirestore _firestore; // Inject Firestore dependency

  WorkProgressViewModel(this.workProgressService, this._firestore);

  List<WorkProgress> _workProgressList = [];
  bool _isLoading = false;
  StreamSubscription<List<WorkProgress>>? _progressSubscription;

  List<WorkProgress> get workProgressList => _workProgressList;
  bool get isLoading => _isLoading;

  void fetchWorkProgressForLecturer(String lecturerId) {
    _isLoading = true;
    notifyListeners();

    _progressSubscription?.cancel(); // Cancel any existing subscription
    _progressSubscription = workProgressService
        .getWorkProgressForLecturer(lecturerId)
        .listen((progressList) {
      _workProgressList = progressList;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> submitWorkProgress(WorkProgress progress) async {
    try {
      final progressData = {
        'studentId': progress.studentId,
        'lecturerId': progress.lecturerId,
        'progressTitle': progress.progressTitle,
        'progressDescription': progress.progressDescription,
        'submissionDate': progress.submissionDate.toIso8601String(),
        'fileUrl': progress.fileUrl,
      };

      // Example: Save data to Firebase
      await FirebaseFirestore.instance
          .collection('work_progress')
          .add(progressData);
      notifyListeners();
    } catch (e) {
      throw Exception("Error submitting progress: $e");
    }
  }

  Future<void> updateWorkProgress(
      String progressId, Map<String, dynamic> updatedData) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Logic to update progress
      await Future.delayed(Duration(seconds: 1)); // Simulate async operation
      // e.g., Update Firebase or an API record by progressId
    } catch (e) {
      throw Exception("Failed to update work progress: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFeedback(String progressId, String feedback) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('work_progress').doc(progressId).update({
        'feedback': FieldValue.arrayUnion([feedback]),
      });
      print('Feedback added successfully.');
    } catch (e) {
      print('Error adding feedback: $e');
      throw Exception('Adding feedback failed');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }
}
