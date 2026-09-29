import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:labsync/services/signUp/sign_up_service_abstract.dart';

class SignUpServiceImplementation implements SignUpService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> signUp(
    String fullName,
    String matricNumber,
    String email,
    String password,
    String username,
    String role,
    String selectedLecturerId,
  ) async {
    try {
      // Create a user with Firebase Authentication
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Get the user UID from Firebase Authentication
      String userId = userCredential.user?.uid ?? '';

      // Add user data to Firestore
      await _firestore.collection('users').doc(userId).set({
        'fullName': fullName,
        'matricNumber': matricNumber,
        'email': email,
        'role': role,
        'username': username,
        'lecturerId':
            role == 'Student' ? selectedLecturerId : '', // Only for students
        'uid': userId, // Store the UID in the document as well
      });
    } on FirebaseAuthException catch (e) {
      throw Exception('Error during sign up: ${e.message}');
    }
  }

  @override
  Future<List<String>> fetchLecturers() async {
    final lecturerSnapshot = await _firestore.collection('lecturers').get();
    return lecturerSnapshot.docs.map((doc) => doc.id).toList();
  }
}
