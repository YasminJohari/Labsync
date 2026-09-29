import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';

class StudentWorkProgressViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.readonly'],
  );
  final String studentId;

  StudentWorkProgressViewModel({required this.studentId});

  // Stream for real-time work progress updates
  Stream<List<Map<String, dynamic>>> get workProgressStream {
    return _firestore
        .collection('work_progress')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    });
  }

  // Optional: Legacy methods for manual fetching (if needed)
  List<Map<String, dynamic>> _workProgressList = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get workProgressList => _workProgressList;
  bool get isLoading => _isLoading;

  Future<void> fetchWorkProgress() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('work_progress')
          .where('studentId', isEqualTo: studentId)
          .get();

      _workProgressList = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching work progress for student: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Request storage permission (integrated method)
  Future<void> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      print("Storage permission granted");
    } else {
      print("Storage permission denied");
    }
  }

  // Download file from Google Drive with logs
  Future<void> downloadFileFromGoogleDrive(
      String fileUrl, BuildContext context) async {
    try {
      await requestStoragePermission();
      final fileId = _extractFileId(fileUrl);
      if (fileId == null) {
        throw Exception("Invalid Google Drive file URL.");
      }

      print("Starting download for file ID: $fileId");

      // Authenticate and get access token
      final accessToken = await _getGoogleAccessToken();
      print("Successfully authenticated with Google Drive.");

      // Fetch metadata to get file name
      final metadata = await _getFileMetadata(fileId, accessToken);
      final fileName = metadata['name'] ?? 'downloaded_file';

      print("File metadata fetched: ${json.encode(metadata)}");
      print("File name: $fileName");

      // Download the file content
      final fileBytes = await _downloadFileContent(fileId, accessToken);
      print("File content downloaded. Size: ${fileBytes.length} bytes.");

      // Save to Downloads directory
      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        throw Exception("Downloads directory not found.");
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(fileBytes);
      print("File saved to: ${file.path}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File downloaded: ${file.path}')),
      );
    } catch (e) {
      print("Error downloading file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file')),
      );
    }
  }

  // Authenticate and get Google Drive access token
  Future<String> _getGoogleAccessToken() async {
    await _googleSignIn.signOut();
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account == null) {
      throw Exception("Google Sign-In failed. Please try again.");
    }

    final GoogleSignInAuthentication auth = await account.authentication;
    print("Google Sign-In successful. Access token obtained.");
    return auth.accessToken!;
  }

  // Fetch file metadata (e.g., file name)
  Future<Map<String, dynamic>> _getFileMetadata(
      String fileId, String accessToken) async {
    final uri = Uri.parse(
        'https://www.googleapis.com/drive/v3/files/$fileId?fields=name');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      print("File metadata response: ${response.body}");
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch file metadata: ${response.body}');
    }
  }

  // Download file content
  Future<List<int>> _downloadFileContent(
      String fileId, String accessToken) async {
    final uri = Uri.parse(
        'https://www.googleapis.com/drive/v3/files/$fileId?alt=media');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      print("File content downloaded successfully.");
      return response.bodyBytes;
    } else {
      throw Exception('Failed to download file: ${response.body}');
    }
  }

  // Helper to extract file ID from Google Drive URL
  String? _extractFileId(String fileUrl) {
    final idRegex = RegExp(r'\/d\/([a-zA-Z0-9_-]+)|id=([a-zA-Z0-9_-]+)');
    final match = idRegex.firstMatch(fileUrl);
    final fileId = match?.group(1) ?? match?.group(2);
    print("Extracted file ID: $fileId");
    return fileId;
  }
}
