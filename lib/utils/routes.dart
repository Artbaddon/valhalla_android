import 'package:flutter/material.dart';
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
import 'package:valhalla_android/widgets/navigation/auth_gate.dart';

/// Central routing system with protected route support.
class AppRoutes {
  // Route names
  static const String login = '/';
  static const String homeAdmin = '/home-admin';
  static const String homeOwner = '/home-owner';
  static const String detailAdmin = '/detail-admin';
  static const String detailOwner = '/detail-owner';
  static const String changePassword = '/change-password';
  static const String changePasswordProfileAdmin = '/change-password-profile-admin';
  static const String changePasswordProfileOwner = '/change-password-profile-owner';
  static const String recoverPassword = '/recover-password';

  static const String parkingHomeAdmin = '/parking-home-admin';
  // Payments
  static const String paymentsHome = '/payments-home';
  static const String paymentMethods = '/payment-methods';
  static const String paymentMethodForm = '/payment-method-form';
  static const String paymentHistory = '/payment-history';
  // Reservations
  static const String reservationsHome = '/reservations-home';
  static const String reservationForm = '/reservation-form';

  /// Return the correct home route based on role name.
  static String homeForRole(String roleName) =>
      roleName.toLowerCase() == 'admin' ? homeAdmin : homeOwner;

  // Public route builders
  static final Map<String, WidgetBuilder> _public = {
    login: (_) => const LoginPage(),
    recoverPassword: (_) => const RecoverPage(),
    changePassword: (_) => const ChangePasswordPage(),
  };

  // Protected route builders
  static final Map<String, WidgetBuilder> _protected = {
    homeAdmin: (_) => const HomeAdminPage(),
    homeOwner: (_) => const HomeOwnerPage(),
    detailAdmin: (_) => const DetailAdminPage(),
    detailOwner: (_) => const DetailOwnerPage(),
    changePasswordProfileAdmin: (_) => const ChangePasswordProfileAdminPage(),
    changePasswordProfileOwner: (_) => const ChangePasswordProfileOwnerPage(),
    paymentsHome: (_) => const PaymentsHomePage(),
    paymentMethods: (_) => const PaymentMethodsPage(),
    paymentMethodForm: (_) => const PaymentMethodFormPage(),
    paymentHistory: (_) => const PaymentHistoryPage(),
    reservationsHome: (_) => const ReservationsHomePage(),
    reservationForm: (_) => const ReservationFormPage(),
    parkingHomeAdmin: (_) => const ParkingAdminPage(),
    // Legacy profile routes fallback to home screens
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final name = settings.name ?? '';

    WidgetBuilder? builder = _public[name];
    bool isProtected = false;
    if (builder == null) {
      builder = _protected[name];
      if (builder != null) isProtected = true;
    }

    if (builder == null) {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      );
    }

    final resolvedBuilder = builder; // capture non-null

    if (isProtected) {
      return MaterialPageRoute(
        settings: settings,
        builder: (ctx) => AuthGate(child: resolvedBuilder(ctx)),
      );
    }

    return MaterialPageRoute(settings: settings, builder: resolvedBuilder);
  }
}

