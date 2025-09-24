import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/navigation_service.dart';
import '../errors/exceptions.dart';

class DioClient {
  static DioClient? _instance;
  static DioClient get instance => _instance ??= DioClient._internal();
  DioClient._internal();

  late Dio _dio;
  final StorageService _storageService = StorageService.instance;

  Dio get dio => _dio;

  Future<void> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:3000/api', // replace with real API
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_AuthInterceptor(_storageService));
    _dio.interceptors.add(_ErrorInterceptor());
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  NetworkException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Connection timeout. Please check your internet connection.',
          NetworkErrorType.timeout,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final message = _getErrorMessage(error.response?.data);

        switch (statusCode) {
          case 400:
            return NetworkException(message, NetworkErrorType.badRequest);
          case 401:
            return NetworkException(
              'Please login again',
              NetworkErrorType.unauthorized,
            );
          case 403:
            return NetworkException(
              'Access forbidden',
              NetworkErrorType.forbidden,
            );
          case 404:
            return NetworkException(
              'Resource not found',
              NetworkErrorType.notFound,
            );
          case 500:
            return NetworkException(
              'Server error. Try again later',
              NetworkErrorType.serverError,
            );
          default:
            return NetworkException(message, NetworkErrorType.unknown);
        }

      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please check your connection.',
          NetworkErrorType.noConnection,
        );

      default:
        return NetworkException(
          'Something went wrong. Please try again.',
          NetworkErrorType.unknown,
        );
    }
  }

  String _getErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'] ?? 'An error occurred';
    }
    return 'An error occurred';
  }
}

// Auth Interceptor - automatically adds auth token to requests
class _AuthInterceptor extends Interceptor {
  final StorageService _storageService;

  _AuthInterceptor(this._storageService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 🎯 Automatically add auth token to every request
    final token = await _storageService.getSecure('auth_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add other common headers
    options.headers['X-Requested-With'] = 'XMLHttpRequest';

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 🎯 Handle token expiration automatically
    if (err.response?.statusCode == 401) {
      // Token expired - clear local data and redirect to login
      await _storageService.removeSecure('auth_token');
      await _storageService.remove('user_data');
      // Try to navigate to login if app is mounted
      try {
        await NavigationService.toLogin();
      } catch (_) {}
    }

    super.onError(err, handler);
  }
}

// Error Interceptor - logs errors for debugging
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 🔍 Log error details for debugging
    debugPrint('API Error: ${err.message}');
    debugPrint('Status Code: ${err.response?.statusCode}');
    debugPrint('Response Data: ${err.response?.data}');

    super.onError(err, handler);
  }
}
