import 'package:dio/dio.dart';
import 'package:valhalla_android/models/payment/payment_model.dart';
import 'api_service.dart';

class PaymentService {
  final Dio _dio = ApiService().dio;

  Future<List<Payment>> fetchAll() async {
    final res = await _dio.get('/payment'); // adjust path if needed
    final raw = res.data;
    final list = raw is List ? raw : (raw['data'] as List? ?? const []);
    return list.map((e) => Payment.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<Payment>> fetchForOwner(int ownerId) async {
    try {
      final res = await _dio.get('/payment/owner/$ownerId');
      final raw = res.data;

      final list = _extractList(raw);
      return list
          .map((e) => Payment.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return const [];
      }
      rethrow;
    }
  }

  List<Map<String, dynamic>> _extractList(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (raw is Map) {
      if (raw['data'] is List) {
        return (raw['data'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      if (raw['payments'] is List) {
        return (raw['payments'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      if (raw.isEmpty) {
        return const [];
      }
      return [Map<String, dynamic>.from(raw)];
    }

    return const [];
  }

  Future<Payment> fetchById(int id) async {
    final res = await _dio.get('/payment/$id'); // adjust path if needed
    final raw = res.data;
    final map = raw is Map && raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'])
        : Map<String, dynamic>.from(raw as Map);
    return Payment.fromJson(map);
  }

  Future<void> createPayment(Map<String, dynamic> payload) async {
    await _dio.post('/payment', data: payload);
  }

  Future<void> makePayment(int id, Map<String, dynamic> payload) async {
    await _dio.post('/payment/$id/pay', data: payload);
  }
}
