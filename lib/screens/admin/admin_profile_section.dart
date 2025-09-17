import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/utils/routes.dart';
import 'package:valhalla_android/widgets/common/profile_header.dart';
import 'package:valhalla_android/widgets/common/primary_button.dart';

class AdminProfileSection extends StatelessWidget {
  final String displayName;
  const AdminProfileSection({super.key, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ProfileHeader(displayName: displayName),
        const SizedBox(height: 100),
        PrimaryButton(
          label: 'Cambiar contraseña',
          onPressed: () => context.push(AppRoutes.changePasswordProfileAdmin),
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
    );
  }
}
