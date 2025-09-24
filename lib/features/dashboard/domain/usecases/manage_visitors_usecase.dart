import '../entities/visitor.dart';
import '../repositories/admin_repository.dart';
import '../../../../core/errors/exceptions.dart';

/// Use case for managing visitors
class ManageVisitorsUseCase {
  final AdminRepository _repository;

  ManageVisitorsUseCase(this._repository);

  /// Retrieves visitors with optional filters
  Future<List<Visitor>> getVisitors({
    String? statusFilter,
    String? searchQuery,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      return await _repository.getVisitors(
        statusFilter: statusFilter,
        searchQuery: searchQuery,
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      throw const ValidationException('Failed to load visitors');
    }
  }

  /// Retrieves a specific visitor by ID
  Future<Visitor> getVisitorById(int id) async {
    if (id <= 0) {
      throw const ValidationException('Invalid visitor ID');
    }

    try {
      return await _repository.getVisitorById(id);
    } catch (e) {
      throw const ValidationException('Failed to load visitor details');
    }
  }

  /// Updates visitor status with validation
  Future<void> updateVisitorStatus(int visitorId, String status) async {
    if (visitorId <= 0) {
      throw const ValidationException('Invalid visitor ID');
    }

    if (!['active', 'exited', 'pending'].contains(status)) {
      throw const ValidationException('Invalid visitor status');
    }

    try {
      return await _repository.updateVisitorStatus(visitorId, status);
    } catch (e) {
      throw const ValidationException('Failed to update visitor status');
    }
  }

  /// Creates a new visitor with validation
  Future<Visitor> createVisitor({
    required String name,
    required String documentNumber,
    required String hostName,
    int? hostId,
    String? vehiclePlate,
    String? phoneNumber,
  }) async {
    // Validation logic
    if (name.isEmpty) {
      throw const ValidationException('Visitor name is required');
    }

    if (documentNumber.isEmpty) {
      throw const ValidationException('Document number is required');
    }

    if (hostName.isEmpty) {
      throw const ValidationException('Host name is required');
    }

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phoneNumber)) {
        throw const ValidationException('Please enter a valid phone number');
      }
    }

    try {
      return await _repository.createVisitor(
        name: name,
        documentNumber: documentNumber,
        hostName: hostName,
        hostId: hostId,
        vehiclePlate: vehiclePlate,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      throw const ValidationException('Failed to create visitor');
    }
  }
}