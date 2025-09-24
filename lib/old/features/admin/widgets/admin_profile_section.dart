import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/utils/routes.dart';
import 'package:valhalla_android/utils/colors.dart';

class AdminProfileSection extends StatelessWidget {
  final String displayName;
  const AdminProfileSection({super.key, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.purple,
          child: Icon(Icons.person, size: 60, color: AppColors.background),
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.purple,
          ),
        ),
        const SizedBox(height: 100),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.push(AppRoutes.changePasswordProfileAdmin),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple.withOpacity(.9),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Cambiar contraseña',
              style: TextStyle(fontSize: 16, color: AppColors.background),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Consumer<AuthProvider>(
          builder: (_, auth, __) => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await auth.logout();
                if (context.mounted) context.go(AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple.withOpacity(.9),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(fontSize: 16, color: AppColors.background),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
