import 'package:flutter/material.dart';
import 'package:valhalla_android/navigation/route_names.dart';
import 'guards/auth_guard.dart';
import '../features/common/pages/placeholders.dart' hide SplashPage, AdminDashboardPage;
import '../features/dashboard/presentation/pages/admin_dashboard.dart';
import '../features/dashboard/presentation/pages/owner_dashboard.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/notes/presentation/pages/notes_pages.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/payments/presentation/pages/payments_dashboard.dart';
import '../features/reservations/presentation/pages/reservations_dashboard_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _createRoute(const SplashPage(), settings);

      case RouteNames.login:
        return _createRoute(const LoginPage(), settings);
        
      case RouteNames.resetPassword:
        return _createRoute(const ResetPasswordPage(), settings);
      case RouteNames.adminDashboard:
        return _createProtectedRoute(
          const AdminDashboard(),
          settings,
          requiresAuth: true,
          checkRole: true,
        );
      case RouteNames.guardDashboard:
        return _createProtectedRoute(
          const GuardDashboardPage(),
          settings,
          requiresAuth: true,
          checkRole: true,
        );
      case RouteNames.ownerDashboard:
        return _createProtectedRoute(
          const OwnerDashboard(),
          settings,
          requiresAuth: true,
          checkRole: true,
        );
      case RouteNames.profile:
        return _createProtectedRoute(
          const ProfilePage(),
          settings,
          requiresAuth: true,
          checkRole: true,
        );
      case RouteNames.packages:
        return _createProtectedRoute(
          const PackagesPage(),
          settings,
          requiresAuth: true,
          checkRole: true,
        );
      case RouteNames.notes:
        return _createRoute(const NotesListPage(), settings);
      case RouteNames.payments:
        return _createProtectedRoute(
          const PaymentsDashboard(),
          settings,
          requiresAuth: true,
          checkRole: true,
        );
      case RouteNames.reservations:
        return _createProtectedRoute(
          const ReservationsDashboardPage(),
          settings,
          requiresAuth: true,
          checkRole: true,
        );
      default:
        return _createRoute(const NotFoundPage(), settings);
    }
  }

  static Route<dynamic> _createRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Smooth slide transition
        return SlideTransition(
          position: animation.drive(
            Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
          ),
          child: child,
        );
      },
    );
  }

  static Route<dynamic> _createProtectedRoute(
    Widget page,
    RouteSettings settings, {
    bool requiresAuth = false,
    bool checkRole = false,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) {
        return FutureBuilder<bool>(
          future: _checkPermissions(settings.name!, requiresAuth, checkRole),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show loading while checking permissions
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (snapshot.data == true) {
              return page; // ✅ Access granted
            }

            return const Scaffold(
              body: Center(child: Text('Unauthorized')),
            ); // ❌ Access denied
          },
        );
      },
    );
  }

  static Future<bool> _checkPermissions(
    String route,
    bool requiresAuth,
    bool checkRole,
  ) async {
    if (requiresAuth) {
      final isAuthenticated = await AuthGuard.canActivate();
      if (!isAuthenticated) return false; // Not authenticated
    }

    if (checkRole) {
      final hasAccess = RoleGuard.canActivate(route);
      if (!hasAccess) return false; // Role-based access denied
    }

    return true; // All checks passed
  }
}
