import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/admin_stats.dart';

class AdminStatsCards extends StatelessWidget {
  final AdminStats? stats;

  const AdminStatsCards({
    super.key,
    this.stats,
  });

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No hay estadísticas disponibles',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          title: 'Total Usuarios',
          value: stats!.totalUsers.toString(),
          icon: Icons.people,
          color: AppColors.primary,
        ),
        _buildStatCard(
          title: 'Espacios Totales',
          value: stats!.totalParkingSpots.toString(),
          icon: Icons.local_parking,
          color: AppColors.secondary,
        ),
        _buildStatCard(
          title: 'Espacios Disponibles',
          value: stats!.availableParkingSpots.toString(),
          icon: Icons.check_circle,
          color: AppColors.success,
        ),
        _buildStatCard(
          title: 'Total Visitantes',
          value: stats!.totalVisitors.toString(),
          icon: Icons.person_add,
          color: AppColors.info,
        ),
        _buildStatCard(
          title: 'Visitantes Activos',
          value: stats!.activeVisitors.toString(),
          icon: Icons.visibility,
          color: AppColors.warning,
        ),
        _buildStatCard(
          title: 'Total Reservas',
          value: stats!.totalReservations.toString(),
          icon: Icons.event_note,
          color: AppColors.primary.withOpacity(0.7),
        ),
        _buildStatCard(
          title: 'Total Paquetes',
          value: stats!.totalPackages.toString(),
          icon: Icons.inventory,
          color: AppColors.secondary.withOpacity(0.7),
        ),
        _buildStatCard(
          title: 'Ingresos Totales',
          value: '\$${stats!.totalRevenue.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: AppColors.success.withOpacity(0.8),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 6,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}