import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:labsync/models/user_model.dart';
import 'package:labsync/services/login/auth_service_abstract.dart';

class AuthServiceImplementation implements AuthServiceAbstract {
  final FirebaseFirestore firestore;
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;

  AuthServiceImplementation({required this.firestore});

  // Cache the user data in Firestore
  @override
  Future<void> cacheUserData(String userId, User user) async {
    try {
      await firestore.collection('cached_users').doc(userId).set({
        'username': user.username,
        'email': user.email,
        'role': user.role,
        'lecturerId': user.lecturerId ?? '',
      });
    } catch (e) {
      print('Error caching user data: $e');
    }
  }

  // Retrieve the cached user data from Firestore
  @override
  Future<User?> getCachedUser() async {
    try {
      final user =
          fb_auth.FirebaseAuth.instance.currentUser; // Get the current user
      if (user != null) {
        final docSnapshot =
            await firestore.collection('cached_users').doc(user.uid).get();
        if (docSnapshot.exists) {
          final userData = docSnapshot.data()!;
          return User(
            id: user.uid,
            username: userData['username'],
            email: userData['email'],
            role: userData['role'],
            lecturerId: userData['lecturerId'],
            password: '', // No password stored for security
          );
        }
      }
    } catch (e) {
      print('Error retrieving cached user data: $e');
    }
    return null;
  }

  @override
  Future<User?> login(String username, String password) async {
    try {
      // First, try to get the cached user data
      final cachedUser = await getCachedUser();
      if (cachedUser != null) {
        return cachedUser; // Return cached user data if available
      }

      // If no cached user is found, proceed with querying Firestore and Firebase Authentication
      final querySnapshot = await firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // User not found
      }

      // Retrieve user data from Firestore
      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();
      final email = userData['email'];

      // Sign in with Firebase Authentication
      fb_auth.UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final user = User(
        id: userCredential.user!.uid,
        username: username,
        email: email,
        role: userData['role'],
        password: password,
        lecturerId: userData['lecturerId'],
        matricNumber:
            userData['matricNumber'], // Ensure this is fetched correctly
      );

      // Cache the user data for future use
      await cacheUserData(user.id, user);

      return user;
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  @override
  Future<void> register(
      String email, String password, String role, String? lecturerId, String matricNumber) async {
    try {
      // Create a new user in Firebase Authentication
      fb_auth.UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Save user data in Firestore
      await firestore.collection('users').doc(uid).set({
        'uid': uid,
        'username': email.split('@').first,
        'email': email,
        'role': role,
        if (lecturerId != null) 'lecturerId': lecturerId,
        'matricNumber': matricNumber, // Add matricNumber during registration
      });

      // Optionally, cache the user data after registration
      final user = User(
        id: uid,
        username: email.split('@').first,
        email: email,
        role: role,
        password: password,
        lecturerId: lecturerId,
      );

      await cacheUserData(uid, user);
    } catch (e) {
      print('Error registering user: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await fb_auth.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Error sending password reset email: $e");
      rethrow;
    }
  }
}
