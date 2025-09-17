import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/utils/routes.dart';

// Screens
import 'package:valhalla_android/screens/auth/login_page.dart';
import 'package:valhalla_android/screens/auth/recover_page.dart';
import 'package:valhalla_android/screens/auth/change_password_page.dart';
import 'package:valhalla_android/screens/admin/home_admin.dart';
import 'package:valhalla_android/screens/admin/detail_admin_page.dart';
import 'package:valhalla_android/screens/admin/change_password_profile_admin_page.dart';
import 'package:valhalla_android/screens/owner/home_owner.dart';
import 'package:valhalla_android/screens/owner/detail_owner_page.dart';
import 'package:valhalla_android/screens/owner/change_password_profile_owner_page.dart';
import 'package:valhalla_android/screens/payment/payments_home_page.dart';
import 'package:valhalla_android/screens/payment/payment_methods_page.dart';
import 'package:valhalla_android/screens/payment/payment_method_form_page.dart';
import 'package:valhalla_android/screens/payment/payment_history_page.dart';
import 'package:valhalla_android/screens/reservation/reservations_home_page.dart';
import 'package:valhalla_android/screens/reservation/reservation_form_page.dart';
import 'package:valhalla_android/screens/parking/parking_admin.dart';

/// Central GoRouter configuration.
///
/// Key features:
/// - Auth-based redirection (login vs role home) handled in [redirect].
/// - Role guard for admin-only routes (e.g. parking screen).
/// - Public routes enumerated in [AppRoutes.publicRoutes].
/// - Nested route structure groups related child pages under their parent.
///
/// Usage examples:
///   context.go(AppRoutes.homeAdmin);            // Replace location
///   context.push(AppRoutes.paymentsHome);       // Push onto stack
///   context.push("/home-admin/detail");          // Nested child path
///
/// When adding new screens:
/// 1. Add a constant to `routes.dart` (optional but recommended for consistency).
/// 2. If unauthenticated access is required, include the path in `AppRoutes.publicRoutes`.
/// 3. Add a `GoRoute` entry below, nesting under a logical parent when possible.
/// 4. For advanced data passing, prefer query parameters or `extra` on GoRouterState.
class AppRouter {
  AppRouter._();

  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: AppRoutes.login,
      debugLogDiagnostics: true,
      refreshListenable: Listenable.merge([
        // Auth provider triggers re-evaluation of redirects
        context.read<AuthProvider>(),
      ]),
      redirect: (ctx, state) {
        final auth = ctx.read<AuthProvider>();
        final loggedIn = auth.isLoggedIn;
        final loading = auth.status == AuthStatus.loading;
        final goingToLogin = state.fullPath == AppRoutes.login;

        if (loading) return null; // Stay while deciding

        if (!loggedIn && !AppRoutes.publicRoutes.contains(state.fullPath)) {
          return AppRoutes.login;
        }

        if (loggedIn && goingToLogin) {
          // Send user to role-based home
          return AppRoutes.homeForRole(auth.user!.roleName);
        }

        // Role guard examples: only admin can access admin parking route
        if (state.fullPath == AppRoutes.parkingHomeAdmin && auth.user?.roleName.toLowerCase() != 'admin') {
          return AppRoutes.homeForRole(auth.user!.roleName);
        }

        return null; // no redirect
      },
      routes: [
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (ctx, s) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.recoverPassword,
          name: 'recover-password',
          builder: (ctx, s) => const RecoverPage(),
        ),
        GoRoute(
          path: AppRoutes.changePassword,
          name: 'change-password',
          builder: (ctx, s) => const ChangePasswordPage(),
        ),
        // Admin home + nested
        GoRoute(
          path: AppRoutes.homeAdmin,
          name: 'home-admin',
          builder: (ctx, s) => const HomeAdminPage(),
          routes: [
            GoRoute(
              path: 'detail',
              name: 'detail-admin',
              builder: (ctx, s) => const DetailAdminPage(),
            ),
            GoRoute(
              path: 'change-password-profile',
              name: 'change-password-profile-admin',
              builder: (ctx, s) => const ChangePasswordProfileAdminPage(),
            ),
            GoRoute(
              path: 'parking',
              name: 'parking-home-admin',
              builder: (ctx, s) => const ParkingAdminPage(),
            ),
          ],
        ),
        // Owner home + nested
        GoRoute(
          path: AppRoutes.homeOwner,
          name: 'home-owner',
          builder: (ctx, s) => const HomeOwnerPage(),
          routes: [
            GoRoute(
              path: 'detail',
              name: 'detail-owner',
              builder: (ctx, s) => const DetailOwnerPage(),
            ),
            GoRoute(
              path: 'change-password-profile',
              name: 'change-password-profile-owner',
              builder: (ctx, s) => const ChangePasswordProfileOwnerPage(),
            ),
          ],
        ),
        // Payments (shared)
        GoRoute(
          path: AppRoutes.paymentsHome,
            name: 'payments-home',
            builder: (ctx, s) => const PaymentsHomePage(),
            routes: [
              GoRoute(
                path: 'methods',
                name: 'payment-methods',
                builder: (ctx, s) => const PaymentMethodsPage(),
                routes: [
                  GoRoute(
                    path: 'form',
                    name: 'payment-method-form',
                    builder: (ctx, s) => const PaymentMethodFormPage(),
                  ),
                ],
              ),
              GoRoute(
                path: 'history',
                name: 'payment-history',
                builder: (ctx, s) => const PaymentHistoryPage(),
              ),
            ]
        ),
        // Reservations
        GoRoute(
          path: AppRoutes.reservationsHome,
          name: 'reservations-home',
          builder: (ctx, s) => const ReservationsHomePage(),
          routes: [
            GoRoute(
              path: 'form',
              name: 'reservation-form',
              builder: (ctx, s) => const ReservationFormPage(),
            ),
          ],
        ),
      ],
      errorBuilder: (ctx, state) => const Scaffold(
        body: Center(child: Text('Page not found')),
      ),
    );
  }
}
