import '../repositories/auth_repository.dart';
import '../entities/auth_result_entity.dart';
import '../../../../core/errors/exceptions.dart';

/// Use case for handling user login
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Executes login process with validation
  Future<AuthResultEntity> call({
    required String username,
    required String password,
  }) async {
    // Business validation logic
    if (username.isEmpty || password.isEmpty) {
      throw const ValidationException('Username and password are required');
    }

    if (!_isValidUsername(username)) {
      throw const ValidationException('Please enter a valid username');
    }

    if (password.length < 6) {
      throw const ValidationException('Password must be at least 6 characters');
    }

    // If all validations pass, call repository
    return await _repository.login(username: username, password: password);
  }

  bool _isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9._-]{3,}$').hasMatch(username);
  }
}
