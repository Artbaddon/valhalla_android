import '../../domain/entities/owner_stats.dart';
import '../../domain/repositories/owner_repository.dart';
import '../datasources/owner_remote_datasource.dart';

/// Implementation of owner repository
class OwnerRepositoryImpl implements OwnerRepository {
  final OwnerRemoteDataSource _remoteDataSource;

  OwnerRepositoryImpl(this._remoteDataSource);

  @override
  Future<OwnerStats> getOwnerStats() async {
    final model = await _remoteDataSource.getOwnerStats();
    return OwnerStats(
      totalReservations: model.totalReservations,
      activeReservations: model.activeReservations,
      totalPayments: model.totalPayments,
      pendingPayments: model.pendingPayments,
    );
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    return await _remoteDataSource.updateProfile(
      name: name,
      email: email,
      phone: phone,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}