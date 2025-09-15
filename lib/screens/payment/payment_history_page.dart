import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:valhalla_android/utils/colors.dart';

// Payment history table (right screenshot)
class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = List.generate(8, (i) => {
          'name': 'Sample User ${i + 1}',
          'position': i % 2 == 0 ? 'Software Engineer' : 'Product Designer',
        });

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
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    headingRowHeight: 42,
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Position')),
                      DataColumn(label: Icon(CupertinoIcons.eye)),
                    ],
                    rows: rows
                        .map(
                          (r) => DataRow(cells: [
                            DataCell(Text(r['name']!)),
                            DataCell(Text(r['position']!)),
                            const DataCell(Icon(CupertinoIcons.eye, size: 18)),
                          ]),
                        )
                        .toList(),
                  ),
                ),
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



