import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:valhalla_android/utils/colors.dart';

// Payment method detail / form screen (center screenshot)
class PaymentMethodFormPage extends StatelessWidget {
  const PaymentMethodFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const _PaymentsAppBar(title: 'Valhalla'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LabeledField(label: 'Full Name'),
            const SizedBox(height: 16),
            _LabeledField(label: 'Street Address'),
            const SizedBox(height: 16),
            _LabeledField(label: 'State'),
            const SizedBox(height: 16),
            _LabeledField(label: 'City'),
            const SizedBox(height: 16),
            _LabeledField(label: 'Postal Code'),
            const SizedBox(height: 28),
            Row(
              children: [
                Switch(
                  value: true,
                  activeColor: AppColors.purple,
                  onChanged: (_) {},
                ),
                const SizedBox(width: 4),
                const Text('SET AS DEFAULT', style: TextStyle(fontSize: 12, letterSpacing: .5, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.purple),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Delete', style: TextStyle(color: AppColors.purple, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save', style: TextStyle(fontSize: 14, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  const _LabeledField({required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            hintText: 'Placeholders',
            hintStyle: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      ],
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



