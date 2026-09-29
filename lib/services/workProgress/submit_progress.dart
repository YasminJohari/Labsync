import 'dart:io';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:http/http.dart' as http;

class SubmitProgress extends StatefulWidget {
  final String studentId;
  final String lecturerId;

  const SubmitProgress(
      {required this.studentId, required this.lecturerId, Key? key})
      : super(key: key);

  @override
  _SubmitProgressState createState() => _SubmitProgressState();
}

class _SubmitProgressState extends State<SubmitProgress> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedFile;
  bool _isSubmitting = false;

  // Google Sign-In setup
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard(
    scopes: [drive.DriveApi.driveFileScope],
  );

  // Function to authenticate and return a Drive API client
  Future<drive.DriveApi?> _getDriveClient() async {
    try {
      // Sign out the previous session if exists
      await _googleSignIn.signOut();

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        throw Exception("Sign-in process aborted by the user.");
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      final client = authenticatedClient(
        http.Client(),
        AccessCredentials(
          AccessToken(
            'Bearer',
            auth.accessToken!,
            DateTime.now().add(Duration(hours: 1)).toUtc(),
          ),
          null,
          [drive.DriveApi.driveFileScope],
        ),
      );

      return drive.DriveApi(client);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Google Sign-In error: $e"),
      ));
      return null;
    }
  }

  // Function to pick file using the file picker dialog
  Future<void> _selectFile() async {
    try {
      final params = OpenFileDialogParams(
        dialogType: OpenFileDialogType.document,
        fileExtensionsFilter: ['pdf', 'doc', 'docx', 'png', 'jpg'],
      );
      final filePath = await FlutterFileDialog.pickFile(params: params);

      if (filePath != null) {
        setState(() {
          _selectedFile = File(filePath);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error selecting file: $e"),
      ));
    }
  }

// Function to upload file to Google Drive and set it as publicly accessible
  Future<String?> _uploadFileToDrive(File file) async {
    final driveClient = await _getDriveClient();
    if (driveClient == null) return null;

    try {
      print("Uploading file to Google Drive...");

      var fileToUpload = drive.File()..name = file.uri.pathSegments.last;

      // Uploading the file
      var response = await driveClient.files.create(
        fileToUpload,
        uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
      );

      print("File upload response: $response");

      if (response != null && response.id != null) {
        final fileId = response.id!;

        // Set the permissions to make the file public
        await _makeFilePublic(driveClient, fileId);

        // Construct the public URL
        final publicUrl = 'https://drive.google.com/uc?id=$fileId';
        print("File uploaded and set to public: $publicUrl");

        return publicUrl; // Return the public URL
      } else {
        print("No response or ID received for file upload.");
        return null;
      }
    } catch (e) {
      print("Error uploading file to Google Drive: $e");

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Google Drive upload error: $e"),
      ));

      return null;
    }
  }

  Future<void> _makeFilePublic(
      drive.DriveApi driveClient, String fileId) async {
    try {
      // Create a permission to make the file public
      final permission = drive.Permission()
        ..role = 'reader' // 'reader' grants read-only access
        ..type = 'anyone'; // Make it accessible to anyone with the link

      // Apply the permission to the file
      await driveClient.permissions.create(permission, fileId);
      print("File set to public");
    } catch (e) {
      print("Error making file public: $e");

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error making file public: $e"),
      ));
    }
  }

// Function to submit the progress along with file URL to Firestore
  Future<void> _submitProgress() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("All fields and file selection are required."),
      ));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Upload the file to Google Drive and get its URL
    final String? fileUrl = await _uploadFileToDrive(_selectedFile!);

    if (fileUrl == null) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final submissionData = {
      'studentId': widget.studentId,
      'lecturerId': widget.lecturerId,
      'progressTitle': _titleController.text,
      'progressDescription': _descriptionController.text,
      'submissionDate': Timestamp.now(),
      'workStatus': 'submitted',
      'comments': '',
      'fileUrl': fileUrl, // Ensure this line includes the correct file URL
    };

    try {
      final firestore = FirebaseFirestore.instance;
      // Save the submission in the 'work_progress' collection
      await firestore.collection('work_progress').add(submissionData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Progress submitted successfully!"),
      ));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error submitting progress: $e"),
      ));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Submit Work Progress"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Progress Details",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center the text
                  children: [
                    Text(
                      "Attach File",
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center, // Align the text to center
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width:
                          double.infinity, // Stretch the button to full width
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.attach_file),
                        label: Text("Attach File"),
                        onPressed: _selectFile,
                      ),
                    ),
                    if (_selectedFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Chip(
                          avatar: Icon(Icons.file_present),
                          label: Text(_selectedFile!.path.split('/').last),
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: _isSubmitting
                  ? CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitProgress,
                        child: Text("Submit"),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
