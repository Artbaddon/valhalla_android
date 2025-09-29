import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/models/payment/payment_model.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/screens/payment/payment_method_form_page.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:valhalla_android/utils/navigation_config.dart';
import 'package:valhalla_android/utils/routes.dart';
import 'package:valhalla_android/widgets/navigation/app_bottom_nav.dart';
import 'package:valhalla_android/widgets/navigation/top_navbar.dart';

class PaymentMethodsArgs {
  const PaymentMethodsArgs({required this.payment});

  final Payment payment;
}

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key, required this.args});

  final PaymentMethodsArgs args;

  static const List<String> _methods = [
    'CASH',
    'CARD',
    'TRANSFER',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.role;
    if (role == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final config = roleNavigation[role]!;
    final navItems = config.navItems;
    final navIndex = navItems.indexWhere(
      (item) => item.route == AppRoutes.paymentsHome,
    );
    final currentIndex = navIndex == -1 ? 0 : navIndex;

    final payment = args.payment;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopNavbar(role: role),
      bottomNavigationBar: AppBottomNav(
        items: navItems,
        currentIndex: currentIndex,
        onTap: (index) {
          final route = navItems[index].route;
          context.go(route);
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  BackButton(),
                  SizedBox(width: 8),
                  Text(
                    'Seleccionar método',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
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
                        'Detalle del pago',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        payment.referenceNumber.isNotEmpty
                            ? payment.referenceNumber
                            : 'Pago ${payment.id}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text('Total: \$${payment.totalPayment}',
                          style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text('Estado: ${payment.statusName}',
                          style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Métodos disponibles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _methods.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final method = _methods[index];
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final result = await context.push<bool>(
                            AppRoutes.paymentMake,
                            extra: PaymentMakeArgs(
                              payment: payment,
                              presetMethod: method,
                            ),
                          );
                          if (result == true && context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.lila,
                                child: Text(
                                  method.substring(0, 1),
                                  style: const TextStyle(
                                    color: AppColors.purple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  method,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.purple),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



