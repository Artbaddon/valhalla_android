import 'package:dio/dio.dart';
import '../models/admin_stats_model.dart';
import '../models/parking_spot_model.dart';
import '../models/visitor_model.dart';

/// Remote data source for admin dashboard operations
abstract class AdminRemoteDataSource {
  Future<AdminStatsModel> getAdminStats();
  Future<List<ParkingSpotModel>> getParkingSpots({
    String? typeFilter,
    String? statusFilter,
    String? searchQuery,
  });
  Future<void> updateParkingSpot(ParkingSpotModel parkingSpot);
  Future<List<VisitorModel>> getVisitors({
    String? statusFilter,
    String? searchQuery,
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<VisitorModel> getVisitorById(int id);
  Future<void> updateVisitorStatus(int visitorId, String status);
  Future<VisitorModel> createVisitor({
    required String name,
    required String documentNumber,
    required String hostName,
    int? hostId,
    String? vehiclePlate,
    String? phoneNumber,
  });
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final Dio _dio;
  
  AdminRemoteDataSourceImpl(this._dio);

  @override
  Future<AdminStatsModel> getAdminStats() async {
    try {
      final response = await _dio.get('/admin/stats');
      return AdminStatsModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get admin stats: $e');
    }
  }

  @override
  Future<List<ParkingSpotModel>> getParkingSpots({
    String? typeFilter,
    String? statusFilter,
    String? searchQuery,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (typeFilter != null) queryParams['type'] = typeFilter;
      if (statusFilter != null) queryParams['status'] = statusFilter;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      final response = await _dio.get('/admin/parking-spots', 
        queryParameters: queryParams);
      
      final List<dynamic> data = response.data;
      return data.map((json) => ParkingSpotModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get parking spots: $e');
    }
  }

  @override
  Future<void> updateParkingSpot(ParkingSpotModel parkingSpot) async {
    try {
      await _dio.put('/admin/parking-spots/${parkingSpot.id}', 
        data: parkingSpot.toJson());
    } catch (e) {
      throw Exception('Failed to update parking spot: $e');
    }
  }

  @override
  Future<List<VisitorModel>> getVisitors({
    String? statusFilter,
    String? searchQuery,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (statusFilter != null) queryParams['status'] = statusFilter;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      if (fromDate != null) queryParams['fromDate'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['toDate'] = toDate.toIso8601String();

      final response = await _dio.get('/admin/visitors', 
        queryParameters: queryParams);
      
      final List<dynamic> data = response.data;
      return data.map((json) => VisitorModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get visitors: $e');
    }
  }

  @override
  Future<VisitorModel> getVisitorById(int id) async {
    try {
      final response = await _dio.get('/admin/visitors/$id');
      return VisitorModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get visitor by ID: $e');
    }
  }

  @override
  Future<void> updateVisitorStatus(int visitorId, String status) async {
    try {
      await _dio.patch('/admin/visitors/$visitorId/status', 
        data: {'status': status});
    } catch (e) {
      throw Exception('Failed to update visitor status: $e');
    }
  }

  @override
  Future<VisitorModel> createVisitor({
    required String name,
    required String documentNumber,
    required String hostName,
    int? hostId,
    String? vehiclePlate,
    String? phoneNumber,
  }) async {
    try {
      final response = await _dio.post('/admin/visitors', data: {
        'name': name,
        'documentNumber': documentNumber,
        'hostName': hostName,
        if (hostId != null) 'hostId': hostId,
        if (vehiclePlate != null) 'vehiclePlate': vehiclePlate,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      });
      return VisitorModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create visitor: $e');
    }
  }
}