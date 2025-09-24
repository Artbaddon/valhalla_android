import '../entities/owner_stats.dart';

/// Repository interface for owner dashboard operations
abstract class OwnerRepository {
  /// Retrieves owner statistics for the dashboard
  Future<OwnerStats> getOwnerStats();
  
  /// Updates owner profile information
  Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
  });
  
  /// Changes owner password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}