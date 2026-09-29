abstract class SignUpService {
  Future<void> signUp(String fullName, String matricNumber, String email,
      String password, String username, String role, String selectedLecturerId);
  Future<List<String>> fetchLecturers();
}
