import 'package:dio/dio.dart';
import 'package:valhalla_android/models/visitor/visitor_model.dart';
import 'api_service.dart';

class VisitorService {
  final Dio _dio = ApiService().dio;

  Future<List<Visitor>> fetchAll() async {
    final res = await _dio.get('/visitors'); // adjust path
    final raw = res.data;
    final list = raw is List ? raw : (raw['visitors'] as List? ?? const []);
    return list.map((e) => Visitor.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<Visitor> fetchById(int id) async {
    final res = await _dio.get('/visitors/$id'); // adjust path
    final raw = res.data;
    final map = raw is Map && raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'])
        : Map<String, dynamic>.from(raw as Map);
    return Visitor.fromJson(map);
  }
}
