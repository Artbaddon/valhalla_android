import '../navigation_manager.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/navigation_service.dart';

class AuthGuard {
  static Future<bool> canActivate() async {
    final storageService = StorageService.instance;
    final token = await storageService.getSecure('auth_token');

    if (token == null || token.isEmpty) {
      await NavigationService.toLogin();
      return false; // Not logged in
    }
    return true; // Logged in
  }
}

class RoleGuard {
  static bool canActivate(String route) {
    final navigationManager = NavigationManager.instance;

    if (!navigationManager.canAccesRoute(route)) {
      NavigationService.pushReplacementNamed(
        navigationManager.getDashboardRoute(),
      );
      return false; // Access denied
    }
    return true; // Access granted
  }
}
