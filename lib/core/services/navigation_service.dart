import 'package:flutter/material.dart';
import 'package:valhalla_android/navigation/route_names.dart';

class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState get _nav => navigatorKey.currentState!;

  static Future<T?> pushNamed<T extends Object?>(
    String route, {
    Object? arguments,
  }) {
    return _nav.pushNamed<T>(route, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String route, {
    Object? arguments,
    TO? result,
  }) {
    return _nav.pushReplacementNamed<T, TO>(
      route,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushNamedAndClearStack<T extends Object?>(
    String route, {
    Object? arguments,
  }) {
    return _nav.pushNamedAndRemoveUntil<T>(
      route,
      (route) => false,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>([T? result]) {
    if (_nav.canPop()) _nav.pop<T>(result);
  }

  // Convenience helpers for common destinations
  static Future<void> toLogin() => pushNamedAndClearStack(RouteNames.login);
  static Future<void> toAdminDashboard() =>
      pushNamedAndClearStack(RouteNames.adminDashboard);
  static Future<void> toGuardDashboard() =>
      pushNamedAndClearStack(RouteNames.guardDashboard);
  static Future<void> toOwnerDashboard() =>
      pushNamedAndClearStack(RouteNames.ownerDashboard);
}
