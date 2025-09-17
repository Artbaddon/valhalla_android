import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:valhalla_android/models/payment/payment_model.dart';
import 'package:valhalla_android/services/payment_service.dart';

// Payment history table (right screenshot)
class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final future = PaymentService().fetchAll();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const _PaymentsAppBar(title: 'Valhalla'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Historial', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.purple)),
            const SizedBox(height: 16),
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
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowHeight: 42,
                        columns: const [
                          DataColumn(label: Text('Referencia')),
                          DataColumn(label: Text('Estado')),
                          DataColumn(label: Text('Fecha')),
                          DataColumn(label: Text('Total')),
                          DataColumn(label: Icon(CupertinoIcons.eye)),
                        ],
                        rows: items.map((p) {
                          final date = p.date?.toLocal().toString().split('.').first ?? '—';
                          return DataRow(cells: [
                            DataCell(Text(p.referenceNumber)),
                            DataCell(Text(p.statusName)),
                            DataCell(Text(date)),
                            DataCell(Text('\$${p.totalPayment}')),
                            const DataCell(Icon(CupertinoIcons.eye, size: 18)),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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



