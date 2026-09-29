import 'package:flutter/material.dart';
import 'package:labsync/features/editProfile/viewmodels/edit_profile_viewmodel.dart';
import 'package:map_mvvm/view/view.dart';

class EditProfilePage extends StatelessWidget {
  final String userId;
  final VoidCallback onProfileUpdated;

  const EditProfilePage({
    super.key,
    required this.userId,
    required this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return ViewWrapper<EditProfileViewModel>(
      builder: (context, viewModel) {
        final formKey = GlobalKey<FormState>();

        // Controllers
        final TextEditingController usernameController =
            TextEditingController();
        final TextEditingController fullNameController =
            TextEditingController();
        final TextEditingController matricNumberController =
            TextEditingController();
        final TextEditingController emailController = TextEditingController();
        final TextEditingController lecturerIdController =
            TextEditingController();
        final TextEditingController roleController = TextEditingController();
        final TextEditingController programmeCodeController =
            TextEditingController();
        String? selectedFaculty;
        final TextEditingController roomNoController = TextEditingController();

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Edit Profile Page",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color.fromARGB(255, 99, 29, 59),
          ),
          body: FutureBuilder(
            future: viewModel.getUserInfo(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text('Failed to load profile.'));
              }

              final userData = snapshot.data as Map<String, dynamic>;
              usernameController.text = userData['username'] ?? '';
              fullNameController.text = userData['fullName'] ?? '';
              matricNumberController.text = userData['matricNumber'] ?? '';
              emailController.text = userData['email'] ?? '';
              lecturerIdController.text = userData['lecturerId'] ?? '';
              roleController.text = userData['role'] ?? '';
              programmeCodeController.text = userData['programmeCode'] ?? '';
              selectedFaculty =
                  userData['faculty'] ?? viewModel.faculties.first;
              roomNoController.text = userData['roomNo'] ?? '';

              bool isStudent = userData['role'] == 'Student';
              bool isLecturer = userData['role'] == 'Lecturer';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      _buildTextFormField('Email', emailController.text, false),
                      if (isLecturer)
                        _buildTextFormField(
                            'Lecturer ID', lecturerIdController.text, false),
                      _buildTextFormField('Role', roleController.text, false),
                      _buildTextFormField(
                          'Username', usernameController.text, false),
                      _buildTextFormField(
                          'Full Name', fullNameController.text, true,
                          controller: fullNameController),
                      if (isStudent)
                        _buildTextFormField(
                            'Matric Number', matricNumberController.text, true,
                            controller: matricNumberController),
                      if (isStudent)
                        _buildTextFormField('Programme Code',
                            programmeCodeController.text, true,
                            controller: programmeCodeController,
                            hintText: 'e.g., 2/SECVH',
                            validator: viewModel.validateProgrammeCode),
                      if (isLecturer)
                        _buildTextFormField(
                            'Room No', roomNoController.text, true,
                            controller: roomNoController),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: selectedFaculty,
                          decoration: const InputDecoration(
                            labelText: 'Faculty',
                            border: OutlineInputBorder(),
                          ),
                          items: viewModel.faculties.map((faculty) {
                            return DropdownMenuItem(
                              value: faculty,
                              child: Text(faculty),
                            );
                          }).toList(),
                          onChanged: (value) {
                            selectedFaculty = value;
                          },
                          validator: viewModel.validateFaculty,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result =
                              await _showChangePasswordDialog(context);
                          if (result != null) {
                            String currentPassword = result['currentPassword']!;
                            String newPassword = result['newPassword']!;
                            await viewModel.changePassword(
                                currentPassword, newPassword);
                          }
                        },
                        icon: const Icon(Icons.lock, color: Colors.white),
                        label: const Text('Change Password',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(double.infinity, 55),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (formKey.currentState?.validate() ?? false) {
                            await viewModel.updateProfile(userId, {
                              'fullName': fullNameController.text,
                              'matricNumber': matricNumberController.text,
                              'programmeCode': programmeCodeController.text,
                              'faculty': selectedFaculty ?? '',
                            });
                            Navigator.pop(context, true);
                          }
                        },
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text("Update Profile",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(double.infinity, 55),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTextFormField(String label, String value, bool isEditable,
      {TextEditingController? controller,
      String? hintText,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller ?? TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
        enabled: isEditable,
        validator: validator,
      ),
    );
  }

  Future<Map<String, String>?> _showChangePasswordDialog(
      BuildContext context) async {
    String currentPassword = '';
    String newPassword = '';
    String confirmNewPassword = '';

    return await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Current Password'),
                onChanged: (value) => currentPassword = value,
              ),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                onChanged: (value) => newPassword = value,
              ),
              TextField(
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirm New Password'),
                onChanged: (value) => confirmNewPassword = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null), // Cancel button
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPassword != confirmNewPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match!')),
                  );
                  return;
                }
                Navigator.pop(context, {
                  'currentPassword': currentPassword,
                  'newPassword': newPassword,
                });
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }
}
