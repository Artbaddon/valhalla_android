import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/services/navigation_service.dart';
import 'package:valhalla_android/utils/routes.dart';

/// Wrap protected screens with this gate to ensure user is authenticated.
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Prevent multiple navigations
        if (NavigationService.instance.navigatorKey.currentState?.canPop() ?? false) {
          NavigationService.instance.navigatorKey.currentState!.popUntil((r) => r.isFirst);
        }
        NavigationService.instance.replaceWith(AppRoutes.login);
      });
      return const SizedBox.shrink();
    }

    return child;
  }
}
