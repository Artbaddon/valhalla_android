import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
// colors import no longer needed directly (handled by shared widgets)
import 'package:valhalla_android/utils/routes.dart';
import 'package:valhalla_android/widgets/common/profile_header.dart';
import 'package:valhalla_android/widgets/common/primary_button.dart';

/// Profile section for the owner user (extracted from HomeOwnerPage)
class OwnerProfileSection extends StatelessWidget {
  const OwnerProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const ProfileHeader(displayName: 'OwnerUser'),
            const SizedBox(height: 100),
            PrimaryButton(
              label: 'Cambiar contraseña',
              onPressed: () =>
                  context.push(AppRoutes.changePasswordProfileOwner),
            ),
            const SizedBox(height: 30),
            Consumer<AuthProvider>(
              builder: (_, auth, __) => PrimaryButton(
                label: 'Cerrar Sesión',
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) context.go(AppRoutes.login);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
