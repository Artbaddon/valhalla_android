import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

/// Use case for getting current authenticated user
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  /// Get current authenticated user
  Future<UserEntity?> call() async {
    return await _repository.getCurrentUser();
  }
}