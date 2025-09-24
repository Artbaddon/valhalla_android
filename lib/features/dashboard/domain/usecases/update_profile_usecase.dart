import '../repositories/owner_repository.dart';
import '../../../../core/errors/exceptions.dart';

/// Use case for updating owner profile
class UpdateProfileUseCase {
  final OwnerRepository _repository;

  UpdateProfileUseCase(this._repository);

  /// Updates owner profile with validation
  Future<void> call({
    required String name,
    required String email,
    String? phone,
  }) async {
    // Validation logic
    if (name.isEmpty) {
      throw const ValidationException('Name is required');
    }

    if (email.isEmpty) {
      throw const ValidationException('Email is required');
    }

    if (!_isValidEmail(email)) {
      throw const ValidationException('Please enter a valid email');
    }

    if (phone != null && phone.isNotEmpty && !_isValidPhone(phone)) {
      throw const ValidationException('Please enter a valid phone number');
    }

    // Call repository
    return await _repository.updateProfile(
      name: name,
      email: email,
      phone: phone,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone);
  }
}