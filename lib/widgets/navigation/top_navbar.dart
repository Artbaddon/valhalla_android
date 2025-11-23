import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:valhalla_android/utils/navigation_config.dart';
import 'package:valhalla_android/utils/routes.dart';
import 'package:go_router/go_router.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavbar({super.key, this.role});

  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    final showNotifications =
        role == null || role == UserRole.admin || role == UserRole.owner;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        'Valhalla',
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.purple,
        ),
      ),
      actions: [
        if (showNotifications)
          IconButton(
            onPressed: () {
              context.push(AppRoutes.notification);
            },
            icon: const Icon(
              CupertinoIcons.bell,
              color: AppColors.purple,
              size: 32,
            ),
          ),
        IconButton(
          onPressed: () {
            final rootContext = context;
            //Confirm logout and navigate to login
            showDialog(
              context: rootContext,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Cerrar Sesión'),
                content: const Text(
                  '¿Estás seguro de que deseas cerrar sesión?',
                  style: TextStyle(color: Colors.black),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: AppColors.purple),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      await rootContext.read<AuthProvider>().logout();
                      if (rootContext.mounted) rootContext.go(AppRoutes.login);
                    },
                    child: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: AppColors.purple),
                    ),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.logout, color: AppColors.purple, size: 28),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
