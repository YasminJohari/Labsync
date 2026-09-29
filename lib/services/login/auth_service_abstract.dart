import 'package:labsync/models/user_model.dart';

abstract class AuthServiceAbstract {
  // Check if the user is already cached
  Future<User?> getCachedUser();

  // Cache user data
  Future<void> cacheUserData(String userId, User user);

  // Login with username and password
  Future<User?> login(String username, String password);

  // Register a new user
  Future<void> register(
      String email, String password, String role, String? lecturerId, String matricNumber);
      
  // Forgot password
  Future<void> forgotPassword(String email);
}
