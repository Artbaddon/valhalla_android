import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/models/payment/payment_model.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/services/payment_service.dart';
import 'package:valhalla_android/screens/payment/payment_method_form_page.dart';
import 'package:valhalla_android/services/owner_service.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:valhalla_android/utils/navigation_config.dart';
import 'package:valhalla_android/utils/routes.dart';

/// Payments module home: list of outstanding payments with role-specific actions.
class PaymentsHomePage extends StatefulWidget {
  const PaymentsHomePage({super.key});

  @override
  State<PaymentsHomePage> createState() => _PaymentsHomePageState();
}

class _PaymentsHomePageState extends State<PaymentsHomePage> {
  final PaymentService _service = PaymentService();
  final OwnerService _ownerService = OwnerService();
  Future<List<Payment>>? _future;
  UserRole? _futureRole;
  int? _futureOwnerId;
  int? _currentOwnerId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      _scheduleLoad(auth.role, auth.user?.id);
    });
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthProvider>();
    final role = auth.role;
    final userId = auth.user?.id;
    if (role == null) return;

    // Usar el ownerId en lugar del userId para los pagos
    final next = role == UserRole.owner && _currentOwnerId != null
        ? _service.fetchForOwner(_currentOwnerId!) // ← Usar ownerId aquí
        : _service.fetchAll();

    // Fetch del owner ID si no lo tenemos
    if (role == UserRole.owner && userId != null && _currentOwnerId == null) {
      final owners = await _ownerService.getOwner(userId);
      if (owners.isNotEmpty) {
        setState(() {
          _currentOwnerId = owners.first.ownerId;
        });
      }
    }

    setState(() {
      _future = next;
      _futureRole = role;
      _futureOwnerId = role == UserRole.owner ? userId : null;
    });
    await next;
  }

  void _scheduleLoad(UserRole? role, int? userId) {
    if (role == null) return;
    final desiredOwnerId = role == UserRole.owner ? userId : null;
    if (_future != null &&
        _futureRole == role &&
        _futureOwnerId == desiredOwnerId) {
      return;
    }

    // Primero obtener el ownerId, luego cargar los pagos
    if (role == UserRole.owner && userId != null && _currentOwnerId == null) {
      _ownerService.getOwner(userId).then((owners) {
        if (mounted && owners.isNotEmpty) {
          final ownerId = owners.first.ownerId;
          setState(() {
            _currentOwnerId = ownerId;
          });

          // Ahora cargar los pagos con el ownerId correcto
          final future = _service.fetchForOwner(ownerId);
          setState(() {
            _future = future;
            _futureRole = role;
            _futureOwnerId = desiredOwnerId;
          });
        }
      });
    } else {
      // Si ya tenemos el ownerId o no es owner, cargar normalmente
      final future = role == UserRole.owner && _currentOwnerId != null
          ? _service.fetchForOwner(_currentOwnerId!)
          : _service.fetchAll();

      setState(() {
        _future = future;
        _futureRole = role;
        _futureOwnerId = desiredOwnerId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.role;
    if (role == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isAdmin = role == UserRole.admin;
    final isOwner = role == UserRole.owner;

    if (_futureRole != role ||
        _futureOwnerId != (isOwner ? auth.user?.id : null) ||
        _future == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scheduleLoad(role, auth.user?.id);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              if (isAdmin)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      context.push(AppRoutes.paymentCreate);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Crear pago',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              if (isAdmin && isOwner) const SizedBox(height: 8),
              if (isOwner)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final currentUserId = auth.user?.id;
                        if (currentUserId != null && _currentOwnerId != null) {
                          context.push(
                            AppRoutes.paymentHistory,
                            extra: _currentOwnerId,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'No se encontró información del propietario',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al cargar el historial: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Historial',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FutureBuilder<List<Payment>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final items = snapshot.data ?? const <Payment>[];

              if (items.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text('No tienes pagos pendientes'),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final payment = items[index];
                    return _PaymentCard(
                      payment: payment,
                      isOwner: isOwner,
                      onPay: () {
                        context
                            .push<bool>(
                              AppRoutes.paymentMake, // ← Cambiado a paymentMake
                              extra: PaymentMakeArgs(
                                payment: payment,
                              ), // ← Cambiado a PaymentMakeArgs
                            )
                            .then((result) {
                              if (result == true) {
                                _refresh();
                              }
                            });
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Payment payment;
  final bool isOwner;
  final VoidCallback onPay;

  const _PaymentCard({
    required this.payment,
    required this.isOwner,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final date = payment.date?.toLocal() ?? DateTime.now();
    final formattedDate =
        '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primera fila: Referencia y Estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  payment.referenceNumber.isNotEmpty
                      ? payment.referenceNumber
                      : 'Pago ${payment.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(payment.statusName),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    payment.statusName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Segunda fila: Método de pago y Monto
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Método',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        payment.method,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${payment.amount.toStringAsFixed(0)} ${payment.currency}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tercera fila: Nombre y Fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Propietario',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        payment.ownerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Fecha',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            // Botón Pagar (solo para owners)
            if (isOwner) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onPay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Pagar',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Función para obtener color según el estado
Color _getStatusColor(String statusName) {
  switch (statusName.toLowerCase()) {
    case 'completado':
    case 'approved':
      return Colors.green;
    case 'pendiente':
    case 'pending':
      return Colors.orange;
    case 'rechazado':
    case 'declined':
    case 'error':
      return Colors.red;
    default:
      return Colors.grey;
  }
}