import 'package:flutter/material.dart';
import 'package:valhalla_android/screens/login.dart';
import 'package:valhalla_android/screens/home_admin.dart';
import 'package:valhalla_android/screens/home_owner.dart';
import 'package:valhalla_android/screens/profile_admin.dart';
import 'package:valhalla_android/screens/profile_owner.dart';
import 'package:valhalla_android/screens/detail_admin.dart';
import 'package:valhalla_android/screens/detail_owner.dart';
import 'package:valhalla_android/screens/change_password.dart';
import 'package:valhalla_android/screens/change_password_profile_admin.dart';
import 'package:valhalla_android/screens/change_password_profile_owner.dart';
import 'package:valhalla_android/screens/recover_password.dart';

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
  static const String changePasswordProfileAdmin = '/change-password-profile-admin';
  static const String changePasswordProfileOwner = '/change-password-profile-owner';
  static const String recoverPassword = '/recover-password';

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
        return MaterialPageRoute(
          builder: (_) => const ProfileAdminPage(),
          settings: settings,
        );
      case profileOwner:
        return MaterialPageRoute(
          builder: (_) => const ProfileOwnerPage(),
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
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
    }
  }
}
