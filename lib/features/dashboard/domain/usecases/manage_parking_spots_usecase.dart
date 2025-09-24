import '../entities/parking_spot.dart';
import '../repositories/admin_repository.dart';
import '../../../../core/errors/exceptions.dart';

/// Use case for managing parking spots
class ManageParkingSpotsUseCase {
  final AdminRepository _repository;

  ManageParkingSpotsUseCase(this._repository);

  /// Retrieves parking spots with optional filters
  Future<List<ParkingSpot>> getParkingSpots({
    String? typeFilter,
    String? statusFilter,
    String? searchQuery,
  }) async {
    try {
      return await _repository.getParkingSpots(
        typeFilter: typeFilter,
        statusFilter: statusFilter,
        searchQuery: searchQuery,
      );
    } catch (e) {
      throw const ValidationException('Failed to load parking spots');
    }
  }

  /// Updates a parking spot with validation
  Future<void> updateParkingSpot(ParkingSpot parkingSpot) async {
    // Validation logic
    if (parkingSpot.number.isEmpty) {
      throw const ValidationException('Parking spot number is required');
    }

    if (!['resident', 'visitor'].contains(parkingSpot.type)) {
      throw const ValidationException('Invalid parking spot type');
    }

    if (!['occupied', 'available', 'maintenance'].contains(parkingSpot.status)) {
      throw const ValidationException('Invalid parking spot status');
    }

    try {
      return await _repository.updateParkingSpot(parkingSpot);
    } catch (e) {
      throw const ValidationException('Failed to update parking spot');
    }
  }
}