import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/payment_stats.dart';

class PaymentStatsCards extends StatelessWidget {
  final PaymentStats stats;

  const PaymentStatsCards({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main stats row
        Row(
          children: [
            Expanded(
              child: _buildMainStatCard(
                title: 'Total',
                value: '\$${stats.totalAmount.toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMainStatCard(
                title: 'Este Mes',
                value: '\$${stats.monthlyAmount.toStringAsFixed(2)}',
                icon: Icons.calendar_month,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Secondary stats grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              title: 'Pagos Totales',
              value: stats.totalPayments.toString(),
              icon: Icons.receipt_long,
              color: AppColors.info,
            ),
            _buildStatCard(
              title: 'Completados',
              value: stats.completedPayments.toString(),
              icon: Icons.check_circle,
              color: AppColors.success,
            ),
            _buildStatCard(
              title: 'Pendientes',
              value: stats.pendingPayments.toString(),
              icon: Icons.schedule,
              color: AppColors.warning,
            ),
            _buildStatCard(
              title: 'Fallidos',
              value: stats.failedPayments.toString(),
              icon: Icons.error,
              color: AppColors.error,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Category breakdown
        if (stats.paymentsByCategory.isNotEmpty) ...[
          Text(
            'Por Categoría',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...stats.paymentsByCategory.entries.map((entry) =>
            _buildCategoryItem(entry.key, entry.value),
          ).toList(),
        ],
      ],
    );
  }

  Widget _buildMainStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 28,
                color: color,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  title,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
              size: 28,
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

  Widget _buildCategoryItem(String category, double amount) {
    final percentage = stats.totalAmount > 0 
        ? (amount / stats.totalAmount * 100)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.textMuted.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getCategoryColor(category),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getCategoryName(category),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'parking':
        return AppColors.primary;
      case 'maintenance':
        return AppColors.secondary;
      case 'fine':
        return AppColors.error;
      case 'service':
        return AppColors.info;
      default:
        return AppColors.textMuted;
    }
  }

  String _getCategoryName(String category) {
    switch (category.toLowerCase()) {
      case 'parking':
        return 'Estacionamiento';
      case 'maintenance':
        return 'Mantenimiento';
      case 'fine':
        return 'Multas';
      case 'service':
        return 'Servicios';
      default:
        return category;
    }
  }
}