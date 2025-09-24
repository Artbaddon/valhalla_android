import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/payment_method.dart';

class PaymentMethodsSection extends StatelessWidget {
  final List<PaymentMethod> paymentMethods;
  final bool isLoading;
  final VoidCallback? onAddMethod;
  final Function(PaymentMethod)? onEditMethod;
  final Function(PaymentMethod)? onDeleteMethod;
  final Function(PaymentMethod)? onSetDefault;

  const PaymentMethodsSection({
    super.key,
    required this.paymentMethods,
    this.isLoading = false,
    this.onAddMethod,
    this.onEditMethod,
    this.onDeleteMethod,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with add button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Métodos de Pago',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: onAddMethod,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Agregar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Methods list
        if (isLoading)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          )
        else if (paymentMethods.isEmpty)
          Expanded(child: _buildEmptyState())
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                final method = paymentMethods[index];
                return _buildPaymentMethodCard(method);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_outlined,
            size: 64,
            color: AppColors.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay métodos de pago',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega un método de pago para\nfacilitar tus transacciones',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddMethod,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Método'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: method.isDefault
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                )
              : null,
          border: method.isDefault
              ? Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main info row
            Row(
              children: [
                // Method icon and type
                Container(
                  width: 48,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getMethodColor(method.type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getMethodIcon(method.type),
                    color: _getMethodColor(method.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Method details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            method.name,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (method.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'PREDETERMINADO',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.surface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatMethodDetails(method),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Actions menu
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, method),
                  itemBuilder: (context) => [
                    if (!method.isDefault)
                      const PopupMenuItem(
                        value: 'set_default',
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 20),
                            SizedBox(width: 8),
                            Text('Establecer por defecto'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            size: 20,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Eliminar',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: const Icon(
                    Icons.more_vert,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            // Expiry date if available
            if (method.expiryDate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Vence: ${method.expiryDate}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _isExpiringSoon(method.expiryDate!)
                          ? AppColors.warning
                          : AppColors.textMuted,
                    ),
                  ),
                  if (_isExpiringSoon(method.expiryDate!)) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.warning,
                      size: 16,
                      color: AppColors.warning,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, PaymentMethod method) {
    switch (action) {
      case 'set_default':
        onSetDefault?.call(method);
        break;
      case 'edit':
        onEditMethod?.call(method);
        break;
      case 'delete':
        onDeleteMethod?.call(method);
        break;
    }
  }

  IconData _getMethodIcon(String type) {
    switch (type.toLowerCase()) {
      case 'credit_card':
        return Icons.credit_card;
      case 'debit_card':
        return Icons.credit_card;
      case 'bank_account':
        return Icons.account_balance;
      case 'paypal':
        return Icons.payment;
      case 'digital_wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  Color _getMethodColor(String type) {
    switch (type.toLowerCase()) {
      case 'credit_card':
        return AppColors.primary;
      case 'debit_card':
        return AppColors.secondary;
      case 'bank_account':
        return AppColors.info;
      case 'paypal':
        return const Color(0xFF0070BA);
      case 'digital_wallet':
        return AppColors.success;
      default:
        return AppColors.textMuted;
    }
  }

  String _formatMethodDetails(PaymentMethod method) {
    switch (method.type.toLowerCase()) {
      case 'credit_card':
      case 'debit_card':
        if (method.cardNumber.length >= 4) {
          return '**** **** **** ${method.cardNumber.substring(method.cardNumber.length - 4)}';
        }
        return 'Tarjeta terminada en ****';
      case 'bank_account':
        return 'Cuenta bancaria';
      case 'paypal':
        return 'PayPal - ${method.holderName ?? 'Cuenta'}';
      case 'digital_wallet':
        return 'Billetera digital';
      default:
        return method.type;
    }
  }

  bool _isExpiringSoon(String expiryDate) {
    try {
      // Parse MM/YY format
      final parts = expiryDate.split('/');
      if (parts.length != 2) return false;
      
      final month = int.parse(parts[0]);
      final year = 2000 + int.parse(parts[1]); // Assuming YY format
      
      final expiry = DateTime(year, month);
      final now = DateTime.now();
      final monthsUntilExpiry = (expiry.year - now.year) * 12 + expiry.month - now.month;
      
      return monthsUntilExpiry <= 3; // Expires within 3 months
    } catch (e) {
      return false;
    }
  }
}