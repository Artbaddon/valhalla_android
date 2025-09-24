import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/payment.dart';

class PaymentsList extends StatelessWidget {
  final List<Payment> payments;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final Function(Payment)? onPaymentTap;

  const PaymentsList({
    super.key,
    required this.payments,
    this.isLoading = false,
    this.onRefresh,
    this.onPaymentTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (payments.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          return _buildPaymentCard(payment);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay pagos registrados',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los pagos que realices aparecerán aquí',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => onPaymentTap?.call(payment),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.description,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCategory(payment.category),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${payment.amount.toStringAsFixed(2)}',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getAmountColor(payment.status),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(payment.status),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Payment method and date
              Row(
                children: [
                  Icon(
                    _getPaymentMethodIcon(payment.paymentMethod),
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    payment.paymentMethod,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(payment.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              // Transaction details if available
              if (payment.transactionId?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ID: ${payment.transactionId}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final statusInfo = _getStatusInfo(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusInfo.color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo.icon,
            size: 12,
            color: statusInfo.color,
          ),
          const SizedBox(width: 4),
          Text(
            statusInfo.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: statusInfo.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  StatusInfo _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return StatusInfo(
          label: 'Completado',
          icon: Icons.check_circle,
          color: AppColors.success,
        );
      case 'pending':
        return StatusInfo(
          label: 'Pendiente',
          icon: Icons.schedule,
          color: AppColors.warning,
        );
      case 'failed':
        return StatusInfo(
          label: 'Fallido',
          icon: Icons.error,
          color: AppColors.error,
        );
      case 'processing':
        return StatusInfo(
          label: 'Procesando',
          icon: Icons.sync,
          color: AppColors.info,
        );
      default:
        return StatusInfo(
          label: status,
          icon: Icons.help,
          color: AppColors.textMuted,
        );
    }
  }

  Color _getAmountColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textDark;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'credit_card':
      case 'debit_card':
        return Icons.credit_card;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'paypal':
        return Icons.payment;
      case 'cash':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  String _formatCategory(String category) {
    switch (category.toLowerCase()) {
      case 'parking':
        return 'Estacionamiento';
      case 'maintenance':
        return 'Mantenimiento';
      case 'fine':
        return 'Multa';
      case 'service':
        return 'Servicio';
      default:
        return category;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Ayer ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class StatusInfo {
  final String label;
  final IconData icon;
  final Color color;

  StatusInfo({
    required this.label,
    required this.icon,
    required this.color,
  });
}