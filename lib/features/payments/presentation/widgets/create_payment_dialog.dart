import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_method.dart';

class CreatePaymentDialog extends StatefulWidget {
  final List<PaymentMethod> paymentMethods;
  final Function(Payment) onCreate;

  const CreatePaymentDialog({
    super.key,
    required this.paymentMethods,
    required this.onCreate,
  });

  @override
  State<CreatePaymentDialog> createState() => _CreatePaymentDialogState();
}

class _CreatePaymentDialogState extends State<CreatePaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedCategory = 'parking';
  PaymentMethod? _selectedPaymentMethod;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'value': 'parking', 'label': 'Estacionamiento', 'icon': Icons.local_parking},
    {'value': 'maintenance', 'label': 'Mantenimiento', 'icon': Icons.build},
    {'value': 'fine', 'label': 'Multa', 'icon': Icons.warning},
    {'value': 'service', 'label': 'Servicio', 'icon': Icons.miscellaneous_services},
  ];

  @override
  void initState() {
    super.initState();
    // Set default payment method
    if (widget.paymentMethods.isNotEmpty) {
      _selectedPaymentMethod = widget.paymentMethods.firstWhere(
        (method) => method.isDefault,
        orElse: () => widget.paymentMethods.first,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.payment,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Crear Nuevo Pago',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description field
                      Text(
                        'Descripción',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _getInputDecoration('Describe el pago'),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una descripción';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Amount field
                      Text(
                        'Monto',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        decoration: _getInputDecoration('0.00').copyWith(
                          prefixText: '\$ ',
                          prefixStyle: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa un monto';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Ingresa un monto válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category selection
                      Text(
                        'Categoría',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.textMuted.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: _categories.map((category) {
                            final isSelected = _selectedCategory == category['value'];
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category['value'];
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppColors.primary.withOpacity(0.1)
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: category['value'],
                                      groupValue: _selectedCategory,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCategory = value!;
                                        });
                                      },
                                      activeColor: AppColors.primary,
                                    ),
                                    Icon(
                                      category['icon'],
                                      color: isSelected 
                                          ? AppColors.primary
                                          : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      category['label'],
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: isSelected 
                                            ? AppColors.primary
                                            : AppColors.textDark,
                                        fontWeight: isSelected 
                                            ? FontWeight.bold 
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Payment method selection
                      Text(
                        'Método de Pago',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.paymentMethods.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.warning.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No hay métodos de pago disponibles.\nAgrega uno primero.',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        DropdownButtonFormField<PaymentMethod>(
                          value: _selectedPaymentMethod,
                          decoration: _getInputDecoration('Selecciona método de pago'),
                          items: widget.paymentMethods.map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Row(
                                children: [
                                  Icon(
                                    _getPaymentMethodIcon(method.type),
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      method.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (method.isDefault)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'DEFAULT',
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.surface,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (method) {
                            setState(() {
                              _selectedPaymentMethod = method;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor selecciona un método de pago';
                            }
                            return null;
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading || widget.paymentMethods.isEmpty 
                        ? null 
                        : _createPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.surface,
                            ),
                          )
                        : const Text('Crear Pago'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  IconData _getPaymentMethodIcon(String type) {
    switch (type.toLowerCase()) {
      case 'credit_card':
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

  void _createPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final payment = Payment(
        id: 0, // Will be assigned by backend
        description: _descriptionController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        status: 'pending',
        paymentMethod: _selectedPaymentMethod!.type,
        category: _selectedCategory,
        transactionId: '', // Will be assigned by backend
        createdAt: DateTime.now(),
        userId: 1, // This should come from auth
        userName: 'Usuario', // This should come from auth
      );

      widget.onCreate(payment);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear pago: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}