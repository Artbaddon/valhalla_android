import '../repositories/owner_repository.dart';
import '../../../../core/errors/exceptions.dart';

/// Use case for changing owner password
class ChangePasswordUseCase {
  final OwnerRepository _repository;

  ChangePasswordUseCase(this._repository);

  /// Changes the owner's password with validation
  Future<void> call({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Validation logic
    if (currentPassword.isEmpty) {
      throw const ValidationException('Current password is required');
    }

    if (newPassword.isEmpty) {
      throw const ValidationException('New password is required');
    }

    if (newPassword.length < 6) {
      throw const ValidationException('New password must be at least 6 characters');
    }

    if (newPassword != confirmPassword) {
      throw const ValidationException('Passwords do not match');
    }

    if (currentPassword == newPassword) {
      throw const ValidationException('New password must be different from current password');
    }

    // Call repository
    return await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}