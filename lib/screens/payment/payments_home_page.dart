import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:valhalla_android/utils/routes.dart';

// Payments module: entry list of payable items with Continue buttons
class PaymentsHomePage extends StatelessWidget {
  const PaymentsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': 'Administración', 'amount': '\$150.000'},
      {'title': 'Parqueadero', 'amount': '\$150.000'},
      {'title': 'BBQ', 'amount': '\$150.000'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // History shortcut button (as per screenshot top-left)
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.paymentHistory),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Historial', style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final item = items[index];
              return _PaymentItemCard(
                title: item['title']!,
                amount: item['amount']!,
                onContinue: () => Navigator.pushNamed(context, AppRoutes.paymentMethods),
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
  const _PaymentItemCard({required this.title, required this.amount, required this.onContinue});
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
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
            const SizedBox(height: 20),
            Text(amount, style: const TextStyle(fontSize: 16, color: Colors.black)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('Continuar', style: TextStyle(fontSize: 12, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}



