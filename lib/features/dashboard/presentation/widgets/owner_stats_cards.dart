import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/owner_stats.dart';

class OwnerStatsCards extends StatelessWidget {
  final OwnerStats? stats;

  const OwnerStatsCards({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const Center(
        child: Text('No hay datos disponibles'),
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
          title: 'Total Reservas',
          value: stats!.totalReservations.toString(),
          icon: Icons.event_note,
          color: AppColors.primary,
        ),
        _buildStatCard(
          title: 'Reservas Activas',
          value: stats!.activeReservations.toString(),
          icon: Icons.event_available,
          color: AppColors.success,
        ),
        _buildStatCard(
          title: 'Total Pagos',
          value: '\$${stats!.totalPayments.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: AppColors.info,
        ),
        _buildStatCard(
          title: 'Pagos Pendientes',
          value: stats!.pendingPayments.toString(),
          icon: Icons.pending_actions,
          color: AppColors.warning,
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
      elevation: 4,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}