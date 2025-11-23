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

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      // 1. Datos que el endpoint espera
      final Map<String, dynamic> data = {"email": email};

      // 2. Realizar la solicitud POST con los datos en el cuerpo
      final Response response = await _dio.post(
        'auth/forgot-password',
        data: data, // Aquí se envía el JSON {"email": "..."}
      );

      // 3. Manejar la respuesta exitosa
      if (response.statusCode == 200 || response.statusCode == 201) {
        // El cuerpo de la respuesta es accesible a través de response.data
        final responseData = response.data;

        // Extraer los datos específicos
        final String resetToken = responseData['resetToken'];
        final String expiresAt = responseData['expiresAt'];

        // Devuelve un mapa con el token y la fecha de expiración
        return {'resetToken': resetToken, 'expiresAt': expiresAt};
      } else {
        // Manejo de otros códigos de estado si es necesario
        throw Exception(
          'Failed to reset password: Status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'A network error occurred.';
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      // Manejo de cualquier otro error inesperado (ej. error de parsing local)
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await StorageService.getToken();
    return token != null;
  }
}
