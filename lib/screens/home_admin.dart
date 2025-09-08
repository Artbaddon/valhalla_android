import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:valhalla_android/config/app_routes_fixed.dart';
import 'package:valhalla_android/config/app_colors.dart';
import 'package:valhalla_android/widgets/app_bottom_nav.dart';

class HomeAdminPage extends StatefulWidget {
  const HomeAdminPage({super.key});

  @override
  State<HomeAdminPage> createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  int _currentIndex = 0; // tracks selected bottom tab

  // Simple in-tab profile content replicating original profile design
  Widget _buildProfileContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.purple,
              child: Icon(CupertinoIcons.person, size: 60, color: AppColors.background),
            ),
            const SizedBox(height: 16),
            const Text(
              "UserName",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: 100),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple.withOpacity(.9),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Cambiar contraseña",
                  style: TextStyle(fontSize: 16, color: AppColors.background),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple.withOpacity(.9),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Cerrar Sesión",
                  style: TextStyle(fontSize: 16, color: AppColors.background),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: AppColors.background,
      appBar: AppBar(
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
        ],
      ),
      
    // BODY (only first tab content implemented visually as original)
  body: _currentIndex == 0
      ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Card 1
            _buildInfoCard(
              context,
              title: "Nuevas Amenidades",
              description:
                  "Lorem Ipsum is simply dummy text of the printing and typesetting industry. "
                  "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, "
                  "when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
              image: "asstes/img/megafono.png", 
            ),
            const SizedBox(height: 16),

            // Card 2
            _buildInfoCard(
              context,
              title: "Mantenimiento Programado",
              description:
                  "Lorem Ipsum is simply dummy text of the printing and typesetting industry. "
                  "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, "
                  "when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
              image: "asstes/img/herramienta.png", // herramientas
            ),
          ],
        ),
    )
      : _currentIndex == 6
        ? _buildProfileContent()
        : _buildPlaceholderSection(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        isAdmin: true,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String description,
    required String image,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  color: AppColors.lila,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(image, height: 40, width: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: AppColors.purple),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.detailAdmin);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Leer más",
                  style: TextStyle(color: AppColors.background),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaceholderSection() {
    // Simple placeholder maintaining design style for unimplemented tabs
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(CupertinoIcons.square_grid_2x2, size: 48, color: AppColors.purple),
          SizedBox(height: 16),
          Text(
            'Sección próximamente',
            style: TextStyle(fontSize: 18, color: AppColors.purple, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
