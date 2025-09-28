import 'package:dio/dio.dart';
import 'package:valhalla_android/models/reservation/reservation_model.dart';
import 'api_service.dart';

class ReservationService {
  final Dio _dio = ApiService().dio;

  Future<List<Reservation>> fetchAll() async {
    final res = await _dio.get('/reservations'); // adjust endpoint if needed
    final raw = res.data;
    final list = raw is List ? raw : (raw['data'] as List? ?? const []);
    return list
        .map((e) => Reservation.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Reservation> fetchById(int id) async {
    final res = await _dio.get('/reservations/$id'); // adjust endpoint if needed
    final raw = res.data;
    final map = (raw is Map && raw['data'] is Map)
        ? Map<String, dynamic>.from(raw['data'])
        : Map<String, dynamic>.from(raw as Map);
    return Reservation.fromJson(map);
  }

  Future<Reservation> create(Map<String, dynamic> payload) async {
    final res = await _dio.post('/reservations', data: payload);
    final raw = res.data;
    final map = (raw is Map && raw['data'] is Map)
        ? Map<String, dynamic>.from(raw['data'])
        : Map<String, dynamic>.from(raw as Map);
    return Reservation.fromJson(map);
  }

  Future<Reservation> update(int id, Map<String, dynamic> payload) async {
    final res = await _dio.put('/reservations/$id', data: payload);
    final raw = res.data;
    final map = (raw is Map && raw['data'] is Map)
        ? Map<String, dynamic>.from(raw['data'])
        : Map<String, dynamic>.from(raw as Map);
    return Reservation.fromJson(map);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/reservations/$id');
  }
}
