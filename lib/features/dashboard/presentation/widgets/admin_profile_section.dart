import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';

import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/admin_viewmodel.dart';

class AdminProfileSection extends StatelessWidget {
  const AdminProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, AdminViewModel>(
      builder: (context, authViewModel, adminViewModel, child) {
        final user = authViewModel.currentUser;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mi Perfil',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildProfileCard(user),
              const SizedBox(height: 24),
              _buildAccountSettings(context, authViewModel),
              const SizedBox(height: 24),
              _buildSystemActions(context, adminViewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(dynamic user) {
    return Card(
      elevation: 4,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Administrador',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'admin@valhalla.com',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ADMINISTRADOR',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettings(BuildContext context, AuthViewModel authViewModel) {
    return Card(
      elevation: 4,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración de Cuenta',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.edit,
              title: 'Editar Perfil',
              subtitle: 'Actualizar información personal',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función próximamente disponible'),
                  ),
                );
              },
            ),
            const Divider(),
            _buildSettingItem(
              icon: Icons.lock,
              title: 'Cambiar Contraseña',
              subtitle: 'Actualizar contraseña de acceso',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función próximamente disponible'),
                  ),
                );
              },
            ),
            const Divider(),
            _buildSettingItem(
              icon: Icons.notifications,
              title: 'Notificaciones',
              subtitle: 'Configurar alertas y notificaciones',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función próximamente disponible'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemActions(BuildContext context, AdminViewModel adminViewModel) {
    return Card(
      elevation: 4,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones del Sistema',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.refresh,
              title: 'Actualizar Estadísticas',
              subtitle: 'Recargar datos del sistema',
              onTap: () {
                adminViewModel.loadAdminStats();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Estadísticas actualizadas'),
                  ),
                );
              },
            ),
            const Divider(),
            _buildSettingItem(
              icon: Icons.settings,
              title: 'Configuración del Sistema',
              subtitle: 'Ajustes generales de la aplicación',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función próximamente disponible'),
                  ),
                );
              },
            ),
            const Divider(),
            _buildSettingItem(
              icon: Icons.backup,
              title: 'Respaldo de Datos',
              subtitle: 'Crear copia de seguridad',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función próximamente disponible'),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Consumer<AuthViewModel>(
              builder: (context, authViewModel, child) {
                return SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: authViewModel.isLoading ? 'Cerrando sesión...' : 'Cerrar Sesión',
                    onPressed: authViewModel.isLoading ? null : () async {
                      await authViewModel.logout();
                    },
                    backgroundColor: AppColors.error,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(
        title,
        style: AppTextStyles.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textMuted,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textMuted,
      ),
      onTap: onTap,
    );
  }
}