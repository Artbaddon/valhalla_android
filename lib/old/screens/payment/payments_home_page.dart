import 'package:flutter/material.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:valhalla_android/utils/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:valhalla_android/models/payment/payment_model.dart';
import 'package:valhalla_android/services/payment_service.dart';

// Payments module: entry list of payable items with Continue buttons
class PaymentsHomePage extends StatelessWidget {
  const PaymentsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final future = PaymentService().fetchAll();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // History shortcut button (as per screenshot top-left)
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            onPressed: () => context.push(AppRoutes.paymentHistory),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
        const SizedBox(height: 8),
        Expanded(
          child: FutureBuilder<List<Payment>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final items = snapshot.data ?? const <Payment>[];
              if (items.isEmpty) {
                return const Center(child: Text('No hay pagos'));
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final p = items[index];
                  final amount = '\$${p.totalPayment}';
                  final title = p.referenceNumber.isNotEmpty
                      ? p.referenceNumber
                      : 'Pago ${p.id}';
                  return _PaymentItemCard(
                    title: title,
                    amount: amount,
                    onContinue: () => context.push(AppRoutes.paymentMethods),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PaymentItemCard extends StatelessWidget {
  final String title;
  final String amount;
  final VoidCallback onContinue;
  const _PaymentItemCard({
    required this.title,
    required this.amount,
    required this.onContinue,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      color: AppColors.lila,
      child: Padding(
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 20),
            Text(
              amount,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
