import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/services/payment_service.dart';
import 'package:valhalla_android/utils/colors.dart';


class PaymentCreatePage extends StatefulWidget {
  const PaymentCreatePage({super.key});

  @override
  State<PaymentCreatePage> createState() => _PaymentCreatePageState();
}

class _PaymentCreatePageState extends State<PaymentCreatePage> {
  static const List<String> _paymentTypes = [
    'MAINTENANCE',
    'PARKING',
    'RESERVATION',
    'OTHER',
  ];

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.purple,
  );

  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _ownerCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final PaymentService _service = PaymentService();

  String _selectedType = _paymentTypes.first;
  bool _submitting = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _ownerCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      return;
    }

    final normalizedAmount = _amountCtrl.text.replaceAll(',', '.');
    final amount = double.tryParse(normalizedAmount);
    final ownerId = int.tryParse(_ownerCtrl.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un monto válido.')),
      );
      return;
    }
    if (ownerId == null || ownerId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un ID de propietario válido.')),
      );
      return;
    }

    final payload = {
      'amount': amount,
      'owner_id': ownerId,
      'payment_type': _selectedType,
      'description': _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
    };

    setState(() => _submitting = true);
    try {
      await _service.createPayment(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pago creado correctamente')),
      );
      await Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      String message = 'Error al crear el pago';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['error'] is String) {
          message = data['error'] as String;
        } else if (e.message != null && e.message!.isNotEmpty) {
          message = e.message!;
        }
      } else {
        message = e.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.role;
    if (role == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    BackButton(),
                    SizedBox(width: 8),
                    Text(
                      'Crear pago',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Información del pago',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('Monto', style: _labelStyle),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _amountCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _inputDecoration('Ej. 1000.00'),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Requerido';
                                }
                                final normalized = value.replaceAll(',', '.');
                                final parsed = double.tryParse(normalized);
                                if (parsed == null || parsed <= 0) {
                                  return 'Monto inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Text('Propietario (ID)', style: _labelStyle),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _ownerCtrl,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration('Ej. 1'),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Requerido';
                                }
                                final parsed = int.tryParse(value.trim());
                                if (parsed == null || parsed <= 0) {
                                  return 'ID inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Text('Tipo de pago', style: _labelStyle),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _selectedType,
                              items: _paymentTypes
                                  .map((type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _selectedType = value);
                              },
                              decoration: _inputDecoration('Seleccione un tipo'),
                            ),
                            const SizedBox(height: 16),
                            Text('Descripción', style: _labelStyle),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _descriptionCtrl,
                              decoration: _inputDecoration('Opcional'),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      _submitting ? 'Guardando...' : 'Crear pago',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
