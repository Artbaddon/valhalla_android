import 'package:dio/dio.dart';
import '../models/owner_stats_model.dart';

/// Remote data source for owner dashboard operations
abstract class OwnerRemoteDataSource {
  Future<OwnerStatsModel> getOwnerStats();
  Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class OwnerRemoteDataSourceImpl implements OwnerRemoteDataSource {
  final Dio _dio;
  
  OwnerRemoteDataSourceImpl(this._dio);

  @override
  Future<OwnerStatsModel> getOwnerStats() async {
    try {
      final response = await _dio.get('/owner/stats');
      return OwnerStatsModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get owner stats: $e');
    }
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    try {
      await _dio.put('/owner/profile', data: {
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
      });
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put('/owner/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}