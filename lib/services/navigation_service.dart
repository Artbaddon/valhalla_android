import 'package:flutter/material.dart';

/// A global navigation service to allow navigation without direct BuildContext.
/// Usage: NavigationService.instance.push(AppRoutes.homeAdmin);
class NavigationService {
  NavigationService._internal();
  static final NavigationService instance = NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<T?> push<T extends Object?>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
  }

  Future<T?> replaceWith<T extends Object?, TO extends Object?>(String routeName, {Object? arguments, TO? result}) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(routeName, arguments: arguments, result: result);
  }

  Future<T?> pushAndRemoveUntil<T extends Object?>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(routeName, (route) => false, arguments: arguments);
  }

  void pop<T extends Object?>([T? result]) {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop(result);
    }
  }
}
