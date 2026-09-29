import 'package:flutter/material.dart';
import 'package:labsync/features/editProfile/views/edit_profile_view.dart';
import 'package:labsync/features/editProfile/viewmodels/edit_profile_viewmodel.dart';
import 'package:labsync/features/login/views/login_view.dart';
import 'package:labsync/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:map_mvvm/view/view.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ViewWrapper<ProfileViewModel>(
      builder: (context, viewModel) {
        // Fetch user info after the widget is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!viewModel.dataLoaded && !viewModel.busy) {
            viewModel.fetchUserInfo(userId);
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Profile Page",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color.fromARGB(255, 99, 29, 59),
          ),
          body: viewModel.busy
              ? const Center(child: CircularProgressIndicator())
              : viewModel.userInfo.isEmpty
                  ? const Center(child: Text('No data available.'))
                  : SingleChildScrollView(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              Container(
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: viewModel.userInfo.map((field) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            '${field['label']}:',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.blueGrey),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              field['value'] ?? 'Not available',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black87),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Edit Profile Button
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChangeNotifierProvider.value(
                                        value: EditProfileViewModel(),
                                        child: EditProfilePage(
                                          userId: userId,
                                          onProfileUpdated: () {
                                            // Optionally, manually trigger a refresh if needed
                                            viewModel.fetchUserInfo(userId);
                                          },
                                        ),
                                      ),
                                    ),
                                  );

                                  if (result == true) {
                                    // Refresh the user data after successful update
                                    viewModel.fetchUserInfo(userId);
                                  }
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text("Edit Profile"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 14.0),
                                  textStyle: const TextStyle(fontSize: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  minimumSize: Size(
                                      MediaQuery.of(context).size.width - 40,
                                      55),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Logout Button
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await viewModel.logout(userId);
                                  Navigator.pushAndRemoveUntil(
                                    // ignore: use_build_context_synchronously
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginView()),
                                    (route) => false,
                                  );
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text("Logout"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 14.0),
                                  textStyle: const TextStyle(fontSize: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  minimumSize: Size(
                                      MediaQuery.of(context).size.width - 40,
                                      55),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
        );
      },
    );
  }
}
