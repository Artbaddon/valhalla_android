import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:valhalla_android/utils/routes.dart';
import 'package:go_router/go_router.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final methods = [
      {'icon': 'assets/img/visa.png', 'name': 'Visa'},
      {'icon': 'assets/img/mastercard.png', 'name': 'MasterCard'},
      {'icon': 'assets/img/amex.png', 'name': 'American Express'},
      {'icon': 'assets/img/paypal.png', 'name': 'PayPal'},
      {'icon': 'assets/img/diners.png', 'name': 'Diners'},
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _PaymentsAppBar(title: 'Valhalla'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: ListView.separated(
          itemCount: methods.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final m = methods[index];
            return GestureDetector(
              onTap: () => context.push(AppRoutes.paymentMethodForm),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    // Placeholder for image asset logos
                    Container(
                      width: 42,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.purple.withOpacity(.2)),
                      ),
                      alignment: Alignment.center,
                      child: Text(m['name']!.substring(0, 2), style: const TextStyle(fontSize: 12, color: AppColors.purple)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(m['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                    const Icon(CupertinoIcons.chevron_right, size: 20, color: AppColors.purple),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PaymentsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const _PaymentsAppBar({required this.title});
  @override
  Size get preferredSize => const Size.fromHeight(60);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.background,
      centerTitle: true,
      title: Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.purple)),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(CupertinoIcons.bell, color: AppColors.purple, size: 28),
        ),
      ],
    );
  }
}



