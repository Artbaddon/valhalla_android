import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/owner_viewmodel.dart';
import 'change_password_dialog.dart';
import 'profile_edit_dialog.dart';

class OwnerProfileSection extends StatelessWidget {
  const OwnerProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<OwnerViewModel, AuthViewModel>(
      builder: (context, ownerViewModel, authViewModel, child) {
        final user = authViewModel.currentUser;

        if (user == null) {
          return const Center(
            child: LoadingWidget(message: 'Cargando perfil...'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.username,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.roleName,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Profile Actions
              Text(
                'Gestión de Perfil',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 16),

              // Edit Profile Button
              if (ownerViewModel.isUpdatingProfile)
                const LoadingWidget(message: 'Actualizando perfil...')
              else
                CustomButton(
                  text: 'Editar Perfil',
                  onPressed: () => _showEditProfileDialog(context),
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.textPrimary,
                ),

              const SizedBox(height: 16),

              // Change Password Button
              if (ownerViewModel.isChangingPassword)
                const LoadingWidget(message: 'Cambiando contraseña...')
              else
                CustomButton(
                  text: 'Cambiar Contraseña',
                  onPressed: () => _showChangePasswordDialog(context),
                  backgroundColor: AppColors.secondary,
                  textColor: AppColors.textPrimary,
                ),

              const SizedBox(height: 32),

              // Logout Button
              if (authViewModel.isLoading)
                const LoadingWidget(message: 'Cerrando sesión...')
              else
                CustomButton(
                  text: 'Cerrar Sesión',
                  onPressed: () async {
                    await authViewModel.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                        (route) => false,
                      );
                    }
                  },
                  backgroundColor: AppColors.error,
                  textColor: AppColors.white,
                ),

              const SizedBox(height: 24),

              // Error Message
              if (ownerViewModel.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ownerViewModel.errorMessage!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ProfileEditDialog(),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }
}