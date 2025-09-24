import '../entities/owner_stats.dart';
import '../repositories/owner_repository.dart';
import '../../../../core/errors/exceptions.dart';

/// Use case for retrieving owner dashboard statistics
class GetOwnerStatsUseCase {
  final OwnerRepository _repository;

  GetOwnerStatsUseCase(this._repository);

  /// Retrieves owner statistics data
  Future<OwnerStats> call() async {
    try {
      return await _repository.getOwnerStats();
    } catch (e) {
      throw const ValidationException('Failed to load owner statistics');
    }
  }
}