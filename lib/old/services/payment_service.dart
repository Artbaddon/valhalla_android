import 'package:dio/dio.dart';
import 'package:valhalla_android/models/payment/payment_model.dart';
import 'api_service.dart';

class PaymentService {
  final Dio _dio = ApiService().dio;

  Future<List<Payment>> fetchAll() async {
    final res = await _dio.get('/payment'); // adjust path if needed
    final raw = res.data;
    final list = raw is List ? raw : (raw['data'] as List? ?? const []);
    return list
        .map((e) => Payment.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Payment> fetchById(int id) async {
    final res = await _dio.get('/payment/$id'); // adjust path if needed
    final raw = res.data;
    final map = raw is Map && raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'])
        : Map<String, dynamic>.from(raw as Map);
    return Payment.fromJson(map);
  }
}
