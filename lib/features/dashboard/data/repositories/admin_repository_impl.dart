import '../../domain/entities/admin_stats.dart';
import '../../domain/entities/parking_spot.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

/// Implementation of admin repository
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<AdminStats> getAdminStats() async {
    final model = await _remoteDataSource.getAdminStats();
    return AdminStats(
      totalUsers: model.totalUsers,
      totalParkingSpots: model.totalParkingSpots,
      availableParkingSpots: model.availableParkingSpots,
      totalVisitors: model.totalVisitors,
      activeVisitors: model.activeVisitors,
      totalReservations: model.totalReservations,
      totalPackages: model.totalPackages,
      totalRevenue: model.totalRevenue,
    );
  }

  @override
  Future<List<ParkingSpot>> getParkingSpots({
    String? typeFilter,
    String? statusFilter,
    String? searchQuery,
  }) async {
    final models = await _remoteDataSource.getParkingSpots(
      typeFilter: typeFilter,
      statusFilter: statusFilter,
      searchQuery: searchQuery,
    );
    
    return models.map((model) => ParkingSpot(
      id: model.id,
      number: model.number,
      type: model.type,
      status: model.status,
      ownerName: model.ownerName,
      ownerId: model.ownerId,
      occupiedSince: model.occupiedSince,
      vehiclePlate: model.vehiclePlate,
    )).toList();
  }

  @override
  Future<void> updateParkingSpot(ParkingSpot parkingSpot) async {
    final model = _parkingSpotToModel(parkingSpot);
    return await _remoteDataSource.updateParkingSpot(model);
  }

  @override
  Future<List<Visitor>> getVisitors({
    String? statusFilter,
    String? searchQuery,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final models = await _remoteDataSource.getVisitors(
      statusFilter: statusFilter,
      searchQuery: searchQuery,
      fromDate: fromDate,
      toDate: toDate,
    );
    
    return models.map((model) => Visitor(
      id: model.id,
      name: model.name,
      documentNumber: model.documentNumber,
      hostName: model.hostName,
      hostId: model.hostId,
      enterDate: model.enterDate,
      exitDate: model.exitDate,
      status: model.status,
      vehiclePlate: model.vehiclePlate,
      phoneNumber: model.phoneNumber,
    )).toList();
  }

  @override
  Future<Visitor> getVisitorById(int id) async {
    final model = await _remoteDataSource.getVisitorById(id);
    return Visitor(
      id: model.id,
      name: model.name,
      documentNumber: model.documentNumber,
      hostName: model.hostName,
      hostId: model.hostId,
      enterDate: model.enterDate,
      exitDate: model.exitDate,
      status: model.status,
      vehiclePlate: model.vehiclePlate,
      phoneNumber: model.phoneNumber,
    );
  }

  @override
  Future<void> updateVisitorStatus(int visitorId, String status) async {
    return await _remoteDataSource.updateVisitorStatus(visitorId, status);
  }

  @override
  Future<Visitor> createVisitor({
    required String name,
    required String documentNumber,
    required String hostName,
    int? hostId,
    String? vehiclePlate,
    String? phoneNumber,
  }) async {
    final model = await _remoteDataSource.createVisitor(
      name: name,
      documentNumber: documentNumber,
      hostName: hostName,
      hostId: hostId,
      vehiclePlate: vehiclePlate,
      phoneNumber: phoneNumber,
    );
    
    return Visitor(
      id: model.id,
      name: model.name,
      documentNumber: model.documentNumber,
      hostName: model.hostName,
      hostId: model.hostId,
      enterDate: model.enterDate,
      exitDate: model.exitDate,
      status: model.status,
      vehiclePlate: model.vehiclePlate,
      phoneNumber: model.phoneNumber,
    );
  }

  // Helper method to convert entity to model
  dynamic _parkingSpotToModel(ParkingSpot parkingSpot) {
    return {
      'id': parkingSpot.id,
      'number': parkingSpot.number,
      'type': parkingSpot.type,
      'status': parkingSpot.status,
      'ownerName': parkingSpot.ownerName,
      'ownerId': parkingSpot.ownerId,
      'occupiedSince': parkingSpot.occupiedSince?.toIso8601String(),
      'vehiclePlate': parkingSpot.vehiclePlate,
    };
  }
}