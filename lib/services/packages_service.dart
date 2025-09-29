import 'package:dio/dio.dart';
import 'package:valhalla_android/models/packages/packages_model.dart';
import 'api_service.dart';

class PackagesService {
  final Dio _dio = ApiService().dio;

  Future<List<Packages>> fetchAll() async {
    final res = await _dio.get('/packages'); // adjust endpoint
    final raw = res.data;
    final list = raw is List ? raw : (raw['data'] as List? ?? const []);
    return list.map((e) => Packages.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<Packages>> fetchForOwner(int ownerId) async {
    final res = await _dio.get('/packages/owner/$ownerId');
    final raw = res.data;
    final list = raw is List ? raw : (raw['data'] as List? ?? const []);
    return list.map((e) => Packages.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<Packages> fetchById(String id) async {
    final res = await _dio.get('/packages/$id'); // adjust endpoint
    final raw = res.data;
    final map = raw is Map && raw['data'] is Map ? Map<String, dynamic>.from(raw['data']) : Map<String, dynamic>.from(raw);
    return Packages.fromJson(map);
  }

  Future<void> registerPackage(Map<String, dynamic> payload) async {
    await _dio.post('/packages/register', data: payload);
  }

  Future<void> updateStatus(String packageId, Map<String, dynamic> payload) async {
    await _dio.post('/packages/$packageId/status', data: payload);
  }
}