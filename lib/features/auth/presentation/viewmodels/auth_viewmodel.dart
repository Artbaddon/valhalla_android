import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../navigation/navigation_manager.dart';
import '../../../../core/services/navigation_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  
  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  AuthViewModel({
    required AuthRepository authRepository,
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _authRepository = authRepository,
       _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase;

  /// Called by Splash to restore session and navigate accordingly.
  Future<void> tryAutoLogin() async {
    try {
      final authed = await _authRepository.isAuthenticated();
      if (authed) {
        final user = await _getCurrentUserUseCase();
        if (user != null) {
          _currentUser = user;
          NavigationManager.instance.setUserRole(user.role);
          _navigateBasedOnRole(user.role);
          notifyListeners();
          return;
        }
      }
    } catch (_) {
      // fallthrough to login on any error
    }
    await NavigationService.toLogin();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResult = await _loginUseCase(
        username: username,
        password: password,
      );
      
      _currentUser = authResult.user;
      _isLoading = false;
      
      // Update current role for navigation filtering
      NavigationManager.instance.setUserRole(authResult.user.role);
      
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _logoutUseCase();
      _currentUser = null;
      _errorMessage = null;
      await NavigationService.toLogin();
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  void _navigateBasedOnRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        NavigationService.toAdminDashboard();
        break;
      case UserRole.guard:
        NavigationService.toGuardDashboard();
        break;
      case UserRole.owner:
        NavigationService.toOwnerDashboard();
        break;
    }
  }
}
