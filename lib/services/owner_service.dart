// lib/services/notification_service.dart (o donde esté tu OwnerService)

import 'package:valhalla_android/models/owner/owner_model.dart';
import 'api_service.dart';

class OwnerService {
  final _api = ApiService();

  Future<List<Owner>> getAllOwners() async {
    final response = await _api.dio.get('/owners/details');
    final data = response.data["owners"] as List;
    return data.map((json) => Owner.fromJson(json)).toList();
  }

  Future<List<Owner>> getOwner(int userId) async {
    final response = await _api.dio.get(
      '/owners/search',
      queryParameters: {'user_id': userId},
    );

    final data = response.data;
    if (data['owner'] is List) {
      // Si es una lista
      final ownerList = data['owner'] as List;
      return ownerList.map((json) => Owner.fromJson(json)).toList();
    } else {
      // Si es un objeto individual, convertirlo a lista con un elemento
      final ownerMap = data['owner'] as Map<String, dynamic>;
      return [Owner.fromJson(ownerMap)];
    }
  }
}