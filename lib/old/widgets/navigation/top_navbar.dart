import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/utils/routes.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:go_router/go_router.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.background,
      centerTitle: true,
      title: const Text(
        "Valhalla",
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: AppColors.purple,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            CupertinoIcons.bell,
            color: AppColors.purple,
            size: 28,
          ),
        ),
        IconButton(
          onPressed: () {
            //Confirm logout and navigate to login
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cerrar Sesión'),
                content: const Text(
                  '¿Estás seguro de que deseas cerrar sesión?',
                  style: TextStyle(color: Colors.black),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: AppColors.purple),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) context.go(AppRoutes.login);
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
