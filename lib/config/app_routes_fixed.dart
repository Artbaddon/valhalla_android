import 'package:flutter/material.dart';
// Auth module
import 'package:valhalla_android/modules/auth/screens/login_page.dart';
import 'package:valhalla_android/modules/auth/screens/recover_page.dart';
import 'package:valhalla_android/modules/auth/screens/change_password_page.dart';

// Admin module
import 'package:valhalla_android/screens/home_admin.dart'; // existing stateful with embedded profile
import 'package:valhalla_android/modules/admin/screens/detail_admin_page.dart';
import 'package:valhalla_android/modules/admin/screens/change_password_profile_admin_page.dart';

// Owner module
import 'package:valhalla_android/screens/home_owner.dart'; // existing stateful with embedded profile
import 'package:valhalla_android/modules/owner/screens/detail_owner_page.dart';
import 'package:valhalla_android/modules/owner/screens/change_password_profile_owner_page.dart';
// Payments module
import 'package:valhalla_android/modules/payments/screens/payments_home_page.dart';
import 'package:valhalla_android/modules/payments/screens/payment_methods_page.dart';
import 'package:valhalla_android/modules/payments/screens/payment_method_form_page.dart';
import 'package:valhalla_android/modules/payments/screens/payment_history_page.dart';
// Reservations module
import 'package:valhalla_android/modules/reservations/screens/reservations_home_page.dart';
import 'package:valhalla_android/modules/reservations/screens/reservation_form_page.dart';

//Package modulee
import 'package:valhalla_android/modules/package/screens/package_home_page.dart';
import 'package:valhalla_android/modules/package/screens/package_register_page.dart';
import 'package:valhalla_android/modules/package/screens/package_view_package.dart';

class AppRoutes {
  // Route names
  static const String login = '/';
  static const String homeAdmin = '/home-admin';
  static const String homeOwner = '/home-owner';
  static const String profileAdmin = '/profile-admin';
  static const String profileOwner = '/profile-owner';
  static const String detailAdmin = '/detail-admin';
  static const String detailOwner = '/detail-owner';
  static const String changePassword = '/change-password';
  static const String changePasswordProfileAdmin =
      '/change-password-profile-admin';
  static const String changePasswordProfileOwner =
      '/change-password-profile-owner';
  static const String recoverPassword = '/recover-password';
  // Payments
  static const String paymentsHome = '/payments-home';
  static const String paymentMethods = '/payment-methods';
  static const String paymentMethodForm = '/payment-method-form';
  static const String paymentHistory = '/payment-history';
  // Reservations
  static const String reservationsHome = '/reservations-home';
  static const String reservationForm = '/reservation-form';
  //Package
  static const String packageHome = '/package-home';
  static const String packageRegister = '/package-register';
  static const String packageView = '/package-view';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case homeAdmin:
        return MaterialPageRoute(
          builder: (_) => const HomeAdminPage(),
          settings: settings,
        );
      case homeOwner:
        return MaterialPageRoute(
          builder: (_) => const HomeOwnerPage(),
          settings: settings,
        );
      case profileAdmin:
        // Profile now embedded in home admin tabs – fall back to home
        return MaterialPageRoute(
          builder: (_) => const HomeAdminPage(),
          settings: settings,
        );
      case profileOwner:
        // Profile now embedded in home owner tabs – fall back to home
        return MaterialPageRoute(
          builder: (_) => const HomeOwnerPage(),
          settings: settings,
        );
      case detailAdmin:
        return MaterialPageRoute(
          builder: (_) => const DetailAdminPage(),
          settings: settings,
        );
      case detailOwner:
        return MaterialPageRoute(
          builder: (_) => const DetailOwnerPage(),
          settings: settings,
        );
      case changePassword:
        return MaterialPageRoute(
          builder: (_) => const ChangePasswordPage(),
          settings: settings,
        );
      case changePasswordProfileAdmin:
        return MaterialPageRoute(
          builder: (_) => const ChangePasswordProfileAdminPage(),
          settings: settings,
        );
      case changePasswordProfileOwner:
        return MaterialPageRoute(
          builder: (_) => const ChangePasswordProfileOwnerPage(),
          settings: settings,
        );
      case recoverPassword:
        return MaterialPageRoute(
          builder: (_) => const RecoverPage(),
          settings: settings,
        );
      case paymentsHome:
        return MaterialPageRoute(
          builder: (_) => const PaymentsHomePage(),
          settings: settings,
        );
      case paymentMethods:
        return MaterialPageRoute(
          builder: (_) => const PaymentMethodsPage(),
          settings: settings,
        );
      case paymentMethodForm:
        return MaterialPageRoute(
          builder: (_) => const PaymentMethodFormPage(),
          settings: settings,
        );
      case paymentHistory:
        return MaterialPageRoute(
          builder: (_) => const PaymentHistoryPage(),
          settings: settings,
        );
      case reservationsHome:
        return MaterialPageRoute(
          builder: (_) => const ReservationsHomePage(),
          settings: settings,
        );
      case reservationForm:
        return MaterialPageRoute(
          builder: (_) => const ReservationFormPage(),
          settings: settings,
        );
      case packageHome:
        return MaterialPageRoute(
          builder: (_) => const PackagesHomePage(),
          settings: settings,
        );
      case packageRegister:
        return MaterialPageRoute(
          builder: (_) => const RegisterPackagePage(),
          settings: settings,
        );
      case packageView:
        return MaterialPageRoute(
          builder: (_) => const ViewPackagesPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
