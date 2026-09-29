import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:labsync/models/work_progress.dart';

class WorkProgressService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  // Submit Work Progress with file upload
  Future<void> submitWorkProgressWithFile(
      WorkProgress progress, File? file) async {
    try {
      String? fileUrl;

      // If a file is provided, upload it to Firebase and get its URL
      if (file != null) {
        fileUrl = await _uploadFileToFirebase(file);
      }

      // Add work progress data, including fileUrl if available
      await _firestore.collection('work_progress').add({
        ...progress.toFirestore(),
        if (fileUrl != null) 'fileUrl': fileUrl,
      });

      print('Work progress submitted successfully.');
    } catch (e) {
      print('Error submitting work progress with file: $e');
      throw Exception('Submission failed');
    }
  }

  // Get real-time work progress for a lecturer
  Stream<List<WorkProgress>> getWorkProgressForLecturer(String lecturerId) {
    return _firestore
        .collection('work_progress')
        .where('lecturerId', isEqualTo: lecturerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                WorkProgress.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Private helper to upload a file to Firebase Storage
  Future<String> _uploadFileToFirebase(File file) async {
    try {
      // Generate unique file path
      String fileName = file.path.split('/').last;
      String fileExtension = fileName.split('.').last;
      String filePath =
          'uploads/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      Reference storageRef = _storage.ref().child(filePath);

      // Upload the file
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      // Get and return the file URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file to Firebase Storage: $e');
      throw Exception('File upload failed');
    }
  }
}