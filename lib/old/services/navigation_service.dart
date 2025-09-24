import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Deprecated: Prefer using GoRouter's context.go()/context.push().
/// This service remains only for legacy calls; new code should inject BuildContext.
class NavigationService {
  NavigationService._internal();
  static final NavigationService instance = NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
