import 'package:flutter/material.dart';
import 'package:valhalla_android/config/app_colors.dart';
import 'package:valhalla_android/config/app_routes_fixed.dart';

class PackagesHomePage extends StatelessWidget {
  const PackagesHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              'Gestión de Paquetes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.purple,
              ),
            ),
          ),

          // Botón registrar paquete
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.packageRegister),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                padding: const EdgeInsets.symmetric(vertical: 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: const Icon(Icons.inventory_2_outlined, color: Colors.white),
              label: const Text(
                'Registrar paquete',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Botón ver paquetes
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.packageView),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8186D5),
                padding: const EdgeInsets.symmetric(vertical: 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: const Icon(Icons.visibility_outlined, color: Colors.white),
              label: const Text(
                'Ver paquetes',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
