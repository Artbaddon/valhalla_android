import '../entities/user_entity.dart';
import '../entities/auth_result_entity.dart';

abstract class AuthRepository {
  /// Login with username and password
  Future<AuthResultEntity> login({
    required String username,
    required String password,
  });
  
  /// Logout current user
  Future<void> logout();
  
  /// Get current authenticated user
  Future<UserEntity?> getCurrentUser();
  
  /// Check if user is currently authenticated
  Future<bool> isAuthenticated();
  
  /// Refresh authentication token
  Future<AuthResultEntity> refreshToken();
  
  /// Register new user
  Future<AuthResultEntity> register({
    required String username,
    required String email,
    required String password,
  });
  
  /// Reset password
  Future<void> resetPassword({required String email});
  
  /// Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}
