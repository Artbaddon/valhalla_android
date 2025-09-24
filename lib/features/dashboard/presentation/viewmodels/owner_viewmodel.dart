import 'package:flutter/material.dart';
import '../../domain/entities/owner_stats.dart';
import '../../domain/usecases/get_owner_stats_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// View model for owner dashboard functionality
class OwnerViewModel extends ChangeNotifier {
  final GetOwnerStatsUseCase _getOwnerStatsUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  OwnerViewModel(
    this._getOwnerStatsUseCase,
    this._changePasswordUseCase,
    this._updateProfileUseCase,
  );

  // State variables
  OwnerStats? _ownerStats;
  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isChangingPassword = false;
  bool _isUpdatingProfile = false;

  // Getters
  OwnerStats? get ownerStats => _ownerStats;
  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isChangingPassword => _isChangingPassword;
  bool get isUpdatingProfile => _isUpdatingProfile;

  /// Sets the current user
  void setCurrentUser(UserEntity user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Loads owner dashboard statistics
  Future<void> loadOwnerStats() async {
    _setLoading(true);
    _clearError();

    try {
      _ownerStats = await _getOwnerStatsUseCase.call();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Changes the owner's password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isChangingPassword = true;
    _clearError();
    notifyListeners();

    try {
      await _changePasswordUseCase.call(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      _isChangingPassword = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _isChangingPassword = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates the owner's profile
  Future<bool> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    _isUpdatingProfile = true;
    _clearError();
    notifyListeners();

    try {
      await _updateProfileUseCase.call(
        name: name,
        email: email,
        phone: phone,
      );

      // Update current user if successful
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          username: name,
          email: email,
        );
      }

      _isUpdatingProfile = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _isUpdatingProfile = false;
      notifyListeners();
      return false;
    }
  }

  /// Clears any error messages
  void clearError() {
    _clearError();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}