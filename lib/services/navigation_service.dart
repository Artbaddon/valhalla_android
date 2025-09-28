import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Deprecated: Prefer using GoRouter's context.go()/context.push().
/// This service remains only for legacy calls; new code should inject BuildContext.
class NavigationService {
  NavigationService._internal();
  static final NavigationService instance = NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> goTo(String location) async {
    final context = navigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).go(location);
      return;
    }

    final state = navigatorKey.currentState;
    if (state != null) {
      state.pushNamedAndRemoveUntil(location, (route) => false);
    } else {
      debugPrint('NavigationService: navigatorKey is not attached; unable to navigate to $location');
    }
  }

  // Legacy wrappers now internally use GoRouter when context is available.
  Future<void> go(BuildContext context, String location) async {
    context.go(location);
  }

  Future<void> push(BuildContext context, String location) async {
    context.push(location);
  }

  void pop<T extends Object?>(BuildContext context, [T? result]) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
    }
  }
}
