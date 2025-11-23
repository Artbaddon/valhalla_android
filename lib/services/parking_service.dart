import 'package:dio/dio.dart';
import 'package:valhalla_android/models/parking/parking_model.dart';
import 'package:valhalla_android/services/api_service.dart';

class ParkingService {
  final Dio _dio = ApiService().dio;

  Future<List<Parking>> fetchAll() async {
    final res = await _dio.get('/parking');
    final data = res.data is List ? res.data : (res.data['data'] as List);
    return data
        .map<Parking>((e) => Parking.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ParkingType>> getParkingTypes() async {
    final res = await _dio.get('/parking/parking-types');
    final data = res.data is List ? res.data : (res.data['data'] as List);
    return data
        .map<ParkingType>(
          (e) => ParkingType.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<ParkingStatus>> getParkingStatuses() async {
    final res = await _dio.get('/parking/parking-statuses');
    final data = res.data is List ? res.data : (res.data['data'] as List);
    return data
        .map<ParkingStatus>(
          (e) => ParkingStatus.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<Parking> fetchById(int id) async {
    final res = await _dio.get('/parking/$id');
    return Parking.fromJson(res.data);
  }

  Future<Parking> create(Map<String, dynamic> payload) async {
    final res = await _dio.post('/parking', data: payload);
    return Parking.fromJson(res.data);
  }

  Future<Parking> update(int id, Map<String, dynamic> payload) async {
    final res = await _dio.put('/parking/$id', data: payload);
    return Parking.fromJson(res.data);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/parking/$id');
  }
}
