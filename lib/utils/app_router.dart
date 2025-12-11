import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/services/navigation_service.dart';
import 'package:valhalla_android/utils/navigation_config.dart';
import 'package:valhalla_android/utils/routes.dart';

// Screens
import 'package:valhalla_android/screens/auth/change_password_page.dart';
import 'package:valhalla_android/screens/auth/login_page.dart';
import 'package:valhalla_android/screens/notification/notification_page.dart';
import 'package:valhalla_android/screens/auth/recover_page.dart';
import 'package:valhalla_android/screens/main/home_page.dart';
import 'package:valhalla_android/screens/packages/packages_page.dart';
import 'package:valhalla_android/screens/parking/parking_page.dart';
import 'package:valhalla_android/screens/payment/payment_create_page.dart'
    as payment_create;
import 'package:valhalla_android/screens/payment/payment_history_page.dart';
import 'package:valhalla_android/screens/payment/payment_method_form_page.dart'
    as payment_make;
import 'package:valhalla_android/screens/payment/payments_home_page.dart';
import 'package:valhalla_android/screens/reservation/reservation_form_page.dart';
import 'package:valhalla_android/screens/reservation/reservations_home_page.dart';
import 'package:valhalla_android/screens/visitors/visitors_page.dart';

/// Central GoRouter configuration responsible for auth redirects and role guards.
class AppRouter {
  AppRouter._();

  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: AppRoutes.login,
      debugLogDiagnostics: true,
      navigatorKey: NavigationService.instance.navigatorKey,
      refreshListenable: Listenable.merge([context.read<AuthProvider>()]),
      redirect: (ctx, state) {
        final auth = ctx.read<AuthProvider>();
        final role = auth.role;
        final loggedIn = auth.isLoggedIn;
        final loading = auth.status == AuthStatus.loading;
        final location = state.matchedLocation;

        if (loading) return null;

        final isPublic = AppRoutes.publicRoutes.contains(location);

        if (!loggedIn) {
          return isPublic ? null : AppRoutes.login;
        }

        if (role == null) {
          return AppRoutes.login;
        }

        final config = roleNavigation[role]!;

        if (location == AppRoutes.login) {
          return config.homeRoute;
        }

        if (AppRoutes.homeRoutes.contains(location) &&
            location != config.homeRoute) {
          return config.homeRoute;
        }

        final allowedRoutes = config.allowedRoutes.toSet();
        if (role == UserRole.admin) {
          allowedRoutes.add(AppRoutes.paymentCreate);
          allowedRoutes.add(AppRoutes.paymentMethods);
          allowedRoutes.add(AppRoutes.paymentMake);
        } else if (role == UserRole.owner) {
          allowedRoutes.add(AppRoutes.paymentMethods);
          allowedRoutes.add(AppRoutes.paymentMake);
        }

        if (!allowedRoutes.contains(location) &&
            !AppRoutes.homeRoutes.contains(location)) {
          return config.homeRoute;
        }

        return null;
      },
      routes: [
        GoRoute(path: AppRoutes.login, builder: (ctx, s) => const LoginPage()),
        GoRoute(
          path: AppRoutes.recoverPassword,
          builder: (ctx, s) => const RecoverPage(),
        ),
        GoRoute(
          path: AppRoutes.changePassword,
          builder: (ctx, s) => const ChangePasswordPage(),
        ),
        GoRoute(
          path: AppRoutes.homeAdmin,
          builder: (ctx, s) => const HomePageShell(),
        ),
        GoRoute(
          path: AppRoutes.homeOwner,
          builder: (ctx, s) => const HomePageShell(),
        ),
        GoRoute(
          path: AppRoutes.homeGuard,
          builder: (ctx, s) => const HomePageShell(),
        ),
        GoRoute(
          path: AppRoutes.parkingHome,
          builder: (ctx, s) => const ParkingScreen(),
        ),
        GoRoute(
          path: AppRoutes.paymentsHome,
          builder: (ctx, s) => const PaymentsHomePage(),
        ),
        GoRoute(
          path: AppRoutes.paymentCreate,
          builder: (ctx, s) => const payment_create.PaymentCreatePage(),
        ),
        
        GoRoute(
          path: AppRoutes.paymentMake,
          builder: (ctx, s) {
            final extra = s.extra;
            if (extra is! payment_make.PaymentMakeArgs) {
              return const Scaffold(
                body: Center(child: Text('Pago no disponible')),
              );
            }
            return payment_make.PaymentMakePage(args: extra);
          },
        ),
        GoRoute(
          path: AppRoutes.notification,
          builder: (ctx, s) => const NotificationsPage(),
        ),
        GoRoute(
          path: AppRoutes.paymentHistory,
          builder: (ctx, s) {
            final ownerId = s.extra as int?;
            return PaymentHistoryPage(
              ownerId: ownerId ?? 0,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.reservationsHome,
          builder: (ctx, s) => const ReservationsHomePage(),
        ),
        GoRoute(
          path: AppRoutes.reservationForm,
          builder: (ctx, s) => const ReservationFormPage(),
        ),
        GoRoute(
          path: AppRoutes.packagesHome,
          builder: (ctx, s) => const PackagesAdminScreen(),
        ),
        GoRoute(
          path: AppRoutes.packageForm,
          builder: (ctx, s) => const PackagesAdminScreen(),
        ),
        GoRoute(
          path: AppRoutes.visitorsHome,
          builder: (ctx, s) => const AdminVisitorsPage(),
        ),
        GoRoute(
          path: AppRoutes.visitorForm,
          builder: (ctx, s) => const AdminVisitorsPage(),
        ),
      ],
      errorBuilder: (ctx, state) =>
          const Scaffold(body: Center(child: Text('Page not found'))),
    );
  }
}
