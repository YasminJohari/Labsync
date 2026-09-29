import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class LecturerWorkProgressViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: [drive.DriveApi.driveScope]);
  final String lecturerId;

  LecturerWorkProgressViewModel({required this.lecturerId});

  List<Map<String, dynamic>> _workProgressList = [];
  bool _isLoading = false;
  bool _hasFetched = false;
  final Map<String, StreamSubscription> _commentListeners = {};

  List<Map<String, dynamic>> get workProgressList => _workProgressList;
  bool get isLoading => _isLoading;
  bool get hasFetched => _hasFetched;

  // Fetch work progress from Firestore
  Future<void> fetchWorkProgress() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('work_progress')
          .where('lecturerId', isEqualTo: lecturerId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _workProgressList = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // Attach real-time listener to each work progress document
          _addCommentListener(doc.id);

          return {
            'id': doc.id,
            'comments': data['comments'] ?? '',
            'fileUrl': data['fileUrl'] ?? '',
            'lecturerId': data['lecturerId'] ?? '',
            'progressDescription': data['progressDescription'] ?? '',
            'progressTitle': data['progressTitle'] ?? '',
            'studentId': data['studentId'] ?? '',
            'submissionDate': data['submissionDate'] ?? '',
            'workStatus': data['workStatus'] ?? '',
          };
        }).toList();
      }
    } catch (e) {
      print("Error fetching work progress: $e");
    } finally {
      _isLoading = false;
      _hasFetched = true;
      notifyListeners();
    }
  }

  // Add a listener for real-time updates to the comments field
  void _addCommentListener(String workId) {
    if (_commentListeners.containsKey(workId)) return;

    _commentListeners[workId] = _firestore
        .collection('work_progress')
        .doc(workId)
        .snapshots()
        .listen((snapshot) {
      final updatedData = snapshot.data();
      if (updatedData != null) {
        final updatedComment = updatedData['comments'] ?? '';

        // Update the work progress list with the new comment
        for (var progress in _workProgressList) {
          if (progress['id'] == workId) {
            progress['comments'] = updatedComment;
            break;
          }
        }
        notifyListeners();
      }
    });
  }

  // Dispose all listeners when the ViewModel is disposed
  @override
  void dispose() {
    for (var listener in _commentListeners.values) {
      listener.cancel();
    }
    _commentListeners.clear();
    super.dispose();
  }

  // Request storage permission (integrated method)
  Future<void> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      print("Storage permission granted");
    } else {
      print("Storage permission denied");
    }
  }

  // Authenticate the lecturer with Google Drive using OAuth2
  Future<drive.DriveApi> authenticateWithGoogleDrive() async {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();

    if (account == null) {
      throw Exception("Google Sign-In failed. Please try again.");
    }

    final GoogleSignInAuthentication auth = await account.authentication;
    final authHeaders = {
      'Authorization': 'Bearer ${auth.accessToken}',
    };

    final client = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken(
          'Bearer',
          auth.accessToken!,
          DateTime.now().add(Duration(hours: 1)).toUtc(), // Ensure UTC format
        ),
        null,
        [drive.DriveApi.driveScope],
      ),
    );

    return drive.DriveApi(client);
  }

  // Download file from Google Drive
  Future<void> downloadFileFromGoogleDrive(
      String fileUrl, BuildContext context) async {
    try {
      // Step 1: Request storage permission
      await requestStoragePermission();

      // Step 2: Extract file ID
      final fileId = extractFileId(fileUrl);
      if (fileId == null) {
        print("Error: Invalid Google Drive file URL.");
        throw Exception("Invalid Google Drive file URL.");
      }
      print("File ID extracted: $fileId");

      // Step 3: Authenticate with Google Drive
      final driveApi = await authenticateWithGoogleDrive();
      print("Google Drive authenticated successfully.");

      // Step 4: Fetch file metadata
      final metadataResponse = await driveApi.files.get(
        fileId,
        $fields: 'name',
      );
      if (metadataResponse is! drive.File) {
        print("Error: Failed to fetch file metadata.");
        throw Exception("Failed to fetch file metadata.");
      }
      final fileName = metadataResponse.name ?? 'downloaded_file';
      print("File metadata retrieved: $fileName");

      // Step 5: Download the file content
      final media = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      );
      if (media is! drive.Media) {
        print("Error: Failed to download file content.");
        throw Exception("Failed to download file content.");
      }
      print("File content fetched successfully.");

      final fileBytes = <int>[];
      await for (var chunk in media.stream) {
        fileBytes.addAll(chunk);
      }
      print("File content downloaded: ${fileBytes.length} bytes.");

      // Step 6: Save the file
      if (Platform.isAndroid) {
        final directory = Directory('/storage/emulated/0/Download');
        if (!directory.existsSync()) {
          print("Error: Downloads directory not found.");
          throw Exception("Downloads directory not found.");
        }

        final downloadPath = '${directory.path}/$fileName';
        final file = File(downloadPath);
        await file.writeAsBytes(fileBytes);

        print("File saved to: $downloadPath");

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File saved to: $downloadPath')),
        );
      }
    } catch (e) {
      print("Error downloading file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error downloading file')),
      );
    }
  }

  // Start listening for real-time updates
  void listenToWorkProgress() {
    _isLoading = true;
    notifyListeners();

    _firestore.collection('work_progress').snapshots().listen((snapshot) {
      _workProgressList = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id, // Store the document ID
          'comments': data['comments'] ?? '',
          'fileUrl': data['fileUrl'] ?? '',
          'lecturerId': data['lecturerId'] ?? '',
          'progressDescription': data['progressDescription'] ?? '',
          'progressTitle': data['progressTitle'] ?? '',
          'studentId': data['studentId'] ?? '',
          'submissionDate': data['submissionDate'] ?? '',
          'workStatus': data['workStatus'] ?? '',
        };
      }).toList();

      _isLoading = false;
      notifyListeners();
    });
  }

// Save a comment and update Firestore
  Future<void> saveComment(String workId, String comment) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('work_progress')
          .where('lecturerId', isEqualTo: lecturerId)
          .get();

      for (var doc in query.docs) {
        if (doc.id == workId) {
          // This is the condition to identify the correct document
          final documentRef = doc.reference;
          await documentRef.update({'comments': comment});
          break; // Exit the loop after updating the correct document
        }
      }
    } catch (e) {
      print("Error saving comment: $e");
      rethrow;
    }
  }

  // Helper method to extract file ID from the Google Drive URL
  String? extractFileId(String fileUrl) {
    try {
      final uri = Uri.parse(fileUrl);

      // Check for 'id' parameter in query
      if (uri.queryParameters.containsKey('id')) {
        return uri.queryParameters['id'];
      }

      // For URLs in the form 'https://drive.google.com/uc?id=...'
      final idRegex = RegExp(r'\/d\/([a-zA-Z0-9_-]+)|id=([a-zA-Z0-9_-]+)');
      final match = idRegex.firstMatch(fileUrl);

      if (match != null) {
        return match.group(1) ?? match.group(2);
      }
    } catch (e) {
      print('Error parsing file URL: $e');
    }
    return null;
  }
}
