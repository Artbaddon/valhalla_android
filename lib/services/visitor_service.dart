import 'package:dio/dio.dart';
import 'package:valhalla_android/models/visitor/visitor_model.dart';
import 'api_service.dart';

class VisitorService {
  final Dio _dio = ApiService().dio;

  Future<List<Visitor>> fetchAll() async {
    final res = await _dio.get('/visitors'); // adjust path
    final raw = res.data;
    final list = raw is List ? raw : (raw['visitors'] as List? ?? const []);
    return list
        .map((e) => Visitor.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Visitor>> fetchForOwner(int ownerId) async {
    final res = await _dio.get('/visitors/owner/$ownerId');
    final raw = res.data;
    final list = raw is List ? raw : (raw['visitors'] as List? ?? const []);
    return list
        .map((e) => Visitor.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Visitor> fetchById(int id) async {
    final res = await _dio.get('/visitors/$id');
    final raw = res.data;


    // CORRECCIÓN: Buscar 'visitor' en lugar de 'data'
    final map = raw is Map && raw['visitor'] is Map
        ? Map<String, dynamic>.from(raw['visitor'])
        : raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};

    return Visitor.fromJson(map);
  }

  Future<void> registerVisitor(Map<String, dynamic> payload) async {
    await _dio.post('/visitors', data: payload);
  }

  Future<void> updateStatus(int visitorId, Map<String, dynamic> payload) async {
    await _dio.post('/visitors/$visitorId/status', data: payload);
  }
}
