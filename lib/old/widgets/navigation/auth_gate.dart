import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:valhalla_android/utils/routes.dart';

/// Deprecated: Replaced by GoRouter redirect logic.
/// Retained temporarily for backward compatibility; new screens should not use.
class AuthGate extends StatelessWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.status == AuthStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!auth.isLoggedIn) {
      // Defer navigation to next frame to avoid setState during build.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.go(AppRoutes.login),
      );
      return const SizedBox.shrink();
    }

    return child;
  }
}
