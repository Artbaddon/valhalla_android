import '../repositories/auth_repository.dart';
import '../../../../core/errors/exceptions.dart';

/// Use case for user logout
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  /// Executes logout process
  Future<void> call() async {
    try {
      await _repository.logout();
    } catch (e) {
      throw AuthException('Failed to logout: ${e.toString()}');
    }
  }
}