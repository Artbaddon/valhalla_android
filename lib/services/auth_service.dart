// lib/services/auth_service.dart
import 'package:dio/dio.dart';
import '../../models/auth/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final Dio _dio = ApiService().dio;

  // Login method
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );

      // If login successful, save token and user
      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        final userData = data['user'];

        await StorageService.saveToken(token);
        await StorageService.saveUser(User.fromJson(userData));

        return {'success': true, 'message': 'Login successful'};
      }

      return {'success': false, 'message': 'Login failed'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Login failed',
      };
    }
  }


  // Logout method
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } finally {
      // Always clear local storage, even if API call fails
      await StorageService.clearAll();
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await StorageService.getToken();
    return token != null;
  }
}
