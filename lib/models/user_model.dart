class User {
  String id; // Unique identifier for the user (UID from Firebase)
  final String username; // Username or email (e.g., 'izzah' or 'dr.jumail')
  final String role; // Role of the user ('Student' or 'Lecturer')
  final String email; // User's email
  final String
      password; // User's password (for local validation, not stored in Firestore)
  final String?
      lecturerId; // Optional lecturerId for students, null for lecturers
  final String? fullName;
  final String? matricNumber;
  // Default constructor
  User({
    required this.id,
    required this.username,
    required this.role,
    required this.password,
    required this.email,
    this.lecturerId,
    this.fullName,
    this.matricNumber,
  });

  // Named constructor: From Firestore data
  factory User.fromFirestore(Map<String, dynamic> data) {
    return User(
      id: data['uid'], // Firebase UID
      username: data['username'],
      role: data['role'],
      password: '', // Password is not stored in Firestore for security reasons
      email: data['email'], // Added email
      lecturerId: data['lecturerId'], // Lecturer ID is optional
      matricNumber: data['matricNumber'] ?? '',
      fullName: data['fullName'] ?? '',
    );
  }

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['uid'], // Firebase UID
      username: data['username'],
      role: data['role'],
      password: '', // Password is not stored in Firestore for security reasons
      email: data['email'], // Added email
      lecturerId: data['lecturerId'], // Lecturer ID is optional
      matricNumber: data['matricNumber'] ?? '',
      fullName: data['fullName'] ?? '',
    );
  }

  // Method to convert a User object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'username': username,
      'email': email,
      'role': role,
      'lecturerId': lecturerId ?? '', // If no lecturerId, store an empty string
      'fullName': fullName,
      'matricNumber': matricNumber,
    };
  }
}
