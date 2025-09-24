import '../entities/admin_stats.dart';
import '../entities/parking_spot.dart';
import '../entities/visitor.dart';

/// Repository interface for admin dashboard operations
abstract class AdminRepository {
  /// Retrieves admin statistics for the dashboard
  Future<AdminStats> getAdminStats();
  
  /// Retrieves all parking spots with optional filters
  Future<List<ParkingSpot>> getParkingSpots({
    String? typeFilter,
    String? statusFilter,
    String? searchQuery,
  });
  
  /// Updates a parking spot
  Future<void> updateParkingSpot(ParkingSpot parkingSpot);
  
  /// Retrieves all visitors with optional filters
  Future<List<Visitor>> getVisitors({
    String? statusFilter,
    String? searchQuery,
    DateTime? fromDate,
    DateTime? toDate,
  });
  
  /// Retrieves a specific visitor by ID
  Future<Visitor> getVisitorById(int id);
  
  /// Updates visitor status
  Future<void> updateVisitorStatus(int visitorId, String status);
  
  /// Creates a new visitor entry
  Future<Visitor> createVisitor({
    required String name,
    required String documentNumber,
    required String hostName,
    int? hostId,
    String? vehiclePlate,
    String? phoneNumber,
  });
}