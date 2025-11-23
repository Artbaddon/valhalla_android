import 'package:flutter/foundation.dart';
import '../models/auth/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'package:valhalla_android/utils/navigation_config.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.loading;
  User? _user;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  UserRole? get role {
    switch (user?.roleId) {
      case 1:
        return UserRole.admin;
      case 3:
        return UserRole.security;
      case 2:
        return UserRole.owner;
      default:
        return null;
    }
  }

  // Initialize auth state when app starts
  Future<void> initializeAuth() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      _user = await StorageService.getUser();
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Login method
  Future<bool> login(String username, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(username, password);

    if (result['success']) {
      _user = await StorageService.getUser();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.unauthenticated;
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }
}
