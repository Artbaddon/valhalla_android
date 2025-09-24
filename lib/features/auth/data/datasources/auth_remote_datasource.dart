import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_result_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResultModel> login({
    required String username,
    required String password,
  });
  Future<void> logout();
  Future<AuthResultModel> register({
    required String username,
    required String email,
    required String password,
  });
  Future<void> resetPassword({required String email});
  Future<AuthResultModel> refreshToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<AuthResultModel> login({
    required String username,
    required String password,
  }) async {
    final response = await _dioClient.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      return AuthResultModel.fromJson(response.data);
    } else {
      throw NetworkException(
        'Login failed: Invalid response',
        NetworkErrorType.unknown,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dioClient.post('/auth/logout');
    } catch (e) {
      throw NetworkException(
        'Logout failed: ${e.toString()}',
        NetworkErrorType.unknown,
      );
    }
  }

  @override
  Future<AuthResultModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post(
      '/auth/register',
      data: {
        'username': username,
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 201 && response.data != null) {
      return AuthResultModel.fromJson(response.data);
    } else {
      throw NetworkException(
        'Registration failed: Invalid response',
        NetworkErrorType.unknown,
      );
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    final response = await _dioClient.post(
      '/auth/reset-password',
      data: {'email': email},
    );

    if (response.statusCode != 200) {
      throw NetworkException(
        'Password reset failed: Invalid response',
        NetworkErrorType.unknown,
      );
    }
  }

  @override
  Future<AuthResultModel> refreshToken() async {
    final response = await _dioClient.post('/auth/refresh');

    if (response.statusCode == 200 && response.data != null) {
      return AuthResultModel.fromJson(response.data);
    } else {
      throw NetworkException(
        'Token refresh failed: Invalid response',
        NetworkErrorType.unknown,
      );
    }
  }
}
