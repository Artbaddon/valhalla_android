import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/services/payment_service.dart';
import 'package:valhalla_android/services/owner_service.dart';
import 'package:valhalla_android/utils/colors.dart';

class PaymentCreatePage extends StatefulWidget {
  const PaymentCreatePage({super.key});

  @override
  State<PaymentCreatePage> createState() => _PaymentCreatePageState();
}

class _PaymentCreatePageState extends State<PaymentCreatePage> {
  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.purple,
  );

  List<Map<String, dynamic>> owners = [];
  bool loadingOwners = false;
  String? selectedOwnerId;

  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final PaymentService _service = PaymentService();

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadOwners();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadOwners() async {
    if (loadingOwners) return;
    if (!mounted) return;

    setState(() {
      loadingOwners = true;
    });

    try {
      final ownerService = OwnerService();
      final response = await ownerService.getAllOwners();

      if (!mounted) return;

      // ✅ SIMPLE - Eliminar duplicados por ID
      final seenIds = <int>{};
      final ownersList = <Map<String, dynamic>>[];

      for (final owner in response) {
        if (!seenIds.contains(owner.ownerId)) {
          seenIds.add(owner.ownerId);
          ownersList.add({'id': owner.ownerId, 'name': owner.fullName});
        }
      }

      setState(() {
        owners = ownersList;
        loadingOwners = false;
      });
    } catch (e) {
      print('Error: $e');
      if (!mounted) return;
      setState(() => loadingOwners = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
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

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingrese un monto válido.')));
      return;
    }
    if (selectedOwnerId == null || selectedOwnerId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un propietario')),
      );
      return;
    }

    final payload = {
      'amount': amount,
      'owner_id': int.parse(selectedOwnerId!),
      'payment_type': 'ADMINISTRACION', // Tipo fijo
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
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
                            Text('Propietario', style: _labelStyle),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: selectedOwnerId,
                              decoration: _fieldDecoration(
                                'Seleccione un propietario',
                              ),
                              validator: (value) =>
                                  value == null ? 'Requerido' : null,
                              items: [
                                // Estado de carga
                                if (loadingOwners)
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text('Cargando propietarios...'),
                                      ],
                                    ),
                                  ),

                                // Estado vacío (después de cargar)
                                if (!loadingOwners && owners.isEmpty)
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      'No hay propietarios disponibles',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),

                                // Estado cargado - mostrar owners
                                if (!loadingOwners && owners.isNotEmpty)
                                  ...owners.map((owner) {
                                    return DropdownMenuItem(
                                      value: owner['id'].toString(),
                                      child: Text(
                                        owner['name'] ?? 'Sin nombre',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              ],
                              onChanged: loadingOwners || owners.isEmpty
                                  ? null
                                  : (value) {
                                      setState(() {
                                        selectedOwnerId = value;
                                      });
                                    },
                            ),
                            const SizedBox(height: 16),
                            Text('Tipo de pago', style: _labelStyle),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'ADMINISTRACION',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.purple,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submitting ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.purple,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text(
                                  _submitting ? 'Guardando...' : 'Crear pago',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
