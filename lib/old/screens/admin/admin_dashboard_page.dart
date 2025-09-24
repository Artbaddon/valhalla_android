import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:valhalla_android/screens/admin/admin_info_card.dart';
import 'package:valhalla_android/utils/routes.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminInfoCard(
          title: 'Nuevas Amenidades',
          description:
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s.',
          imageUrl: 'assets/img/megafono.png',
          onTap: () => context.push(AppRoutes.detailAdmin),
        ),
        const SizedBox(height: 16),
        AdminInfoCard(
          title: 'Mantenimiento Programado',
          description:
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s.',
          imageUrl: 'assets/img/herramienta.png',
          onTap: () => context.push(AppRoutes.detailAdmin),
        ),
      ],
    );
  }
}
