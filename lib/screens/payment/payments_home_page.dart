import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/models/payment/payment_model.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/screens/payment/payment_methods_page.dart';
import 'package:valhalla_android/services/payment_service.dart';
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
  Future<List<Payment>>? _future;
  UserRole? _futureRole;
  int? _futureOwnerId;

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
    final ownerId = auth.user?.id;
    if (role == null) return;

    final next = role == UserRole.owner && ownerId != null
        ? _service.fetchForOwner(ownerId)
        : _service.fetchAll();
    setState(() {
      _future = next;
      _futureRole = role;
      _futureOwnerId = role == UserRole.owner ? ownerId : null;
    });
    await next;
  }

  String _formatAmount(num value) {
    if (value is double && value % 1 != 0) {
      return '\$${value.toStringAsFixed(2)}';
    }
    return '\$${value.toString()}';
  }

  void _scheduleLoad(UserRole? role, int? ownerId) {
    if (role == null) return;
    final desiredOwnerId = role == UserRole.owner ? ownerId : null;
    if (_future != null &&
        _futureRole == role &&
        _futureOwnerId == desiredOwnerId) {
      return;
    }

    final future = role == UserRole.owner && ownerId != null
        ? _service.fetchForOwner(ownerId)
        : _service.fetchAll();

    setState(() {
      _future = future;
      _futureRole = role;
      _futureOwnerId = desiredOwnerId;
    });
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
          // <-- Agregamos el Padding aquí
          padding: const EdgeInsets.only(
            left: 16,
          ), // <-- Definimos el padding solo a la izquierda
          child: Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () => context.push(AppRoutes.paymentHistory),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Historial',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
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
                        child: const Center(child: Text('No hay pagos')),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(height: 16),
                        _AdminCreateButton(onCreated: _refresh),
                      ],
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
                  itemCount: items.length + (isAdmin ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (isAdmin && index == items.length) {
                      return _AdminCreateButton(onCreated: _refresh);
                    }

                    final payment = items[index];
                    final title = payment.referenceNumber.isNotEmpty
                        ? payment.referenceNumber
                        : 'Pago ${payment.id}';

                    return _PaymentItemCard(
                      title: title,
                      amount: _formatAmount(payment.totalPayment),
                      status: payment.statusName,
                      onContinue: isOwner
                          ? () {
                              context
                                  .push<bool>(
                                    AppRoutes.paymentMethods,
                                    extra: PaymentMethodsArgs(payment: payment),
                                  )
                                  .then((result) {
                                    if (result == true) {
                                      _refresh();
                                    }
                                  });
                            }
                          : null,
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

class _PaymentItemCard extends StatelessWidget {
  const _PaymentItemCard({
    required this.title,
    required this.amount,
    required this.status,
    required this.onContinue,
  });

  final String title;
  final String amount;
  final String status;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: AppColors.lila,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Total: $amount',
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              'Estado: $status',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            if (onContinue != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onContinue,
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

class _AdminCreateButton extends StatelessWidget {
  const _AdminCreateButton({required this.onCreated});

  final Future<void> Function() onCreated;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          context.push(AppRoutes.paymentCreate);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: const Text(
          'Crear pago',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
