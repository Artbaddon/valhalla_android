import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:valhalla_android/utils/colors.dart';

// Reservation form card + confirm dialogs (matches screenshot flow)
class ReservationFormPage extends StatelessWidget {
  const ReservationFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final zones = ['BBQ', 'Piscina', 'Gimnasio'];
    String selectedZone = zones.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: const Text('Valhalla', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.purple)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.bell, color: AppColors.purple, size: 28))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gestión Zonas Comunes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.purple)),
            const SizedBox(height: 12),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        CircleAvatar(radius: 12, backgroundColor: AppColors.purple, child: Icon(CupertinoIcons.calendar, color: Colors.white, size: 14)),
                        SizedBox(width: 8),
                        Text('Reservar', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Zone type
                    _DropdownField<String>(
                      label: 'Tipo de zona',
                      value: selectedZone,
                      items: zones.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 12),
                    _TextField(label: 'Fecha', hint: '02/11/21', suffix: const Icon(CupertinoIcons.calendar)),
                    const SizedBox(height: 12),
                    _TextField(label: 'Hora', hint: '20:00 - 01:00'),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Expanded(child: _TextField(label: 'Torre', hint: '5')),
                        SizedBox(width: 12),
                        Expanded(child: _TextField(label: 'Apartamento', hint: '108')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showConfirm(context, '¿Está seguro que desea aceptar la solicitud de reserva?'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, padding: const EdgeInsets.symmetric(vertical: 12)),
                            child: const Text('Reservar', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showConfirm(context, '¿Está seguro que desea cancelar la reserva?'),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.purple), padding: const EdgeInsets.symmetric(vertical: 12)),
                            child: const Text('Cancelar', style: TextStyle(color: AppColors.purple)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                child: const Text('Reservar', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirm(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
                    child: const Text('Continuar', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.purple)),
                    child: const Text('Cancelar', style: TextStyle(color: AppColors.purple)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final String hint;
  final Widget? suffix;
  const _TextField({required this.label, required this.hint, this.suffix});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            suffixIcon: suffix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const _DropdownField({required this.label, required this.value, required this.items, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}



