import '../repositories/auth_repository.dart';
import '../../../../core/errors/exceptions.dart';

/// Use case for password recovery
class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  /// Executes password reset process
  Future<void> call({required String email}) async {
    // Validate email format
    if (email.isEmpty) {
      throw const ValidationException('Email is required');
    }

    if (!_isValidEmail(email)) {
      throw const ValidationException('Please enter a valid email address');
    }

    // Call repository to reset password
    await _repository.resetPassword(email: email);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
}