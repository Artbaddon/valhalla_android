// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  Dio get dio => _dio;

  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl:
            'http://localhost:3000/api', // Change this to your actual API URL
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createLoggingInterceptor());
  }

  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // If token expired (401), clear storage
        if (error.response?.statusCode == 401) {
          await StorageService.clearAll();
          // Redirect to login (you'll implement this)
        }
        handler.next(error);
      },
    );
  }

  // Logs all requests for debugging
  Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🚀 REQUEST: ${options.method} ${options.uri}');
        print('📤 DATA: ${options.data}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ RESPONSE: ${response.statusCode}');
        print('📥 DATA: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ ERROR: ${error.message}');
        handler.next(error);
      },
    );
  }
}
