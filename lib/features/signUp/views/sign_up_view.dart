import 'package:flutter/material.dart';
import 'package:labsync/features/login/views/login_view.dart';
import 'package:labsync/features/signUp/viewmodels/sign_up_viewmodel.dart';
import 'package:map_mvvm/view/view.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewWrapper<SignUpViewmodel>(
      builder: (context, viewModel) {
        // Fetch lecturers when the page is initialized
        viewModel.fetchLecturers();

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Sign Up",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color.fromARGB(255, 99, 29, 59),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name field
                  _buildTextFormField('Full Name', (value) {
                    viewModel.fullName = value;
                  }),

                  // Matric Number field
                  _buildTextFormField('Matric Number', (value) {
                    viewModel.matricNumber = value;
                  }),

                  // Email field
                  _buildTextFormField('Email', (value) {
                    viewModel.email = value;
                  }, keyboardType: TextInputType.emailAddress),

                  // Username field
                  _buildTextFormField('Username', (value) {
                    viewModel.username = value;
                  }),

                  // Password field
                  _buildTextFormField('Password', (value) {
                    viewModel.password = value;
                  }, obscureText: true),

                  // Role selection dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButton<String>(
                      value: viewModel.role,
                      onChanged: (String? newValue) {
                        viewModel.changeRole(
                            newValue!); // Use viewModel to update the role
                      },
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text('Select Role'),
                      items: const [
                        DropdownMenuItem(
                            value: 'Student', child: Text('Student')),
                        DropdownMenuItem(
                            value: 'Lecturer', child: Text('Lecturer')),
                      ],
                    ),
                  ),

                  // Lecturer selection dropdown (only for students)
                  if (viewModel.role == 'Student') ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButton<String>(
                        value: viewModel.selectedLecturerId.isEmpty
                            ? null
                            : viewModel
                                .selectedLecturerId, // Set null initially
                        onChanged: (newValue) {
                          if (newValue != null) {
                            viewModel.changeLecturer(
                                newValue); // Update lecturer selection
                          }
                        },
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Select Lecturer'),
                        items: viewModel.lecturerList.isNotEmpty
                            ? viewModel.lecturerList
                                .map((lecturerId) => DropdownMenuItem<String>(
                                      value: lecturerId,
                                      child: Text(lecturerId),
                                    ))
                                .toList()
                            : [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('No lecturers available'),
                                ),
                              ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.signUp(
                        onSuccess: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please verify your account through the email sent.'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginView()),
                          );
                        },
                        onError: (errorMessage) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                      );
                    },
                    child: const Text("Sign Up"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Utility method to build TextFormField
  Widget _buildTextFormField(
    String label,
    ValueChanged<String> onChanged, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}
