// lib/services/notification_service.dart (o donde esté tu OwnerService)

import 'package:valhalla_android/models/owner/owner_model.dart';
import 'api_service.dart';

class OwnerService {
  final _api = ApiService();

  Future<List<Owner>> getAllOwners() async {
    final response = await _api.dio.get('/owners/details');
    // 🚨 CORRECCIÓN: Cambiar "notifications" a "owners"
    final data = response.data["owners"] as List; 
    return data.map((json) => Owner.fromJson(json)).toList();
  }
}