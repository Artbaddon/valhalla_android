import '../entities/admin_stats.dart';
import '../repositories/admin_repository.dart';
import '../../../../core/errors/exceptions.dart';

/// Use case for retrieving admin dashboard statistics
class GetAdminStatsUseCase {
  final AdminRepository _repository;

  GetAdminStatsUseCase(this._repository);

  /// Retrieves admin statistics data
  Future<AdminStats> call() async {
    try {
      return await _repository.getAdminStats();
    } catch (e) {
      throw const ValidationException('Failed to load admin statistics');
    }
  }
}