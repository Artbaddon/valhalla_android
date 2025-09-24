import 'package:flutter/foundation.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/auth_result_model.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_result_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource; // Handles API calls
  final StorageService _storageService; // Handles local storage

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required StorageService storageService,
  }) : _remoteDataSource = remoteDataSource,
       _storageService = storageService;

  @override
  Future<AuthResultEntity> login({
    required String username,
    required String password,
  }) async {
    try {
      final authResult = await _remoteDataSource.login(
        username: username,
        password: password,
      );
      await _storageService.setSecure('auth_token', authResult.token);
      await _storageService.setObject('user_data', authResult.user.toJson());
      return authResult.toEntity();
    } catch (e, st) {
      if (kDebugMode) debugPrint('AuthRepositoryImpl.login error: $e\n$st');
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (e) {
      if (kDebugMode) debugPrint('Server logout failed: $e');
    }

    await _storageService.removeSecure('auth_token');
    await _storageService.remove('user_data');
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final userData = _storageService.getObject('user_data');
    if (userData != null) {
      return UserModel.fromJson(userData).toEntity();
    }
    return null;
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _storageService.getSecure('auth_token');
    return token != null && token.isNotEmpty;
  }

  @override
  Future<AuthResultEntity> refreshToken() async {
    try {
      final authResult = await _remoteDataSource.refreshToken();
      await _storageService.setSecure('auth_token', authResult.token);
      await _storageService.setObject('user_data', authResult.user.toJson());
      return authResult.toEntity();
    } catch (e) {
      throw AuthException('Token refresh failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthResultEntity> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final authResult = await _remoteDataSource.register(
        username: username,
        email: email,
        password: password,
      );
      await _storageService.setSecure('auth_token', authResult.token);
      await _storageService.setObject('user_data', authResult.user.toJson());
      return authResult.toEntity();
    } catch (e) {
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _remoteDataSource.resetPassword(email: email);
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    // This would need to be implemented based on API requirements
    throw UnimplementedError('Change password not yet implemented');
  }
}
