import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:valhalla_android/utils/routes.dart';

// Reservations home: calendar, small reservations list, CTA button
class ReservationsHomePage extends StatefulWidget {
  const ReservationsHomePage({super.key});
  @override
  State<ReservationsHomePage> createState() => _ReservationsHomePageState();
}

class _ReservationsHomePageState extends State<ReservationsHomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title ("Gestión Zonas Comunes")
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text('Gestión Zonas Comunes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.purple)),
          ),
          // Calendar
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(8),
            child: TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
              calendarStyle: const CalendarStyle(todayDecoration: BoxDecoration(color: AppColors.purple, shape: BoxShape.circle)),
            ),
          ),
          const SizedBox(height: 12),

          // Small reservations list
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text('Reservas', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          _ReservationRow(title: 'Torre 5 - APT 103', date: '02/11/21', time: '20:00 - 01:00'),
          const SizedBox(height: 8),
          _ReservationRow(title: 'Torre 1 - APT 210', date: '13/11/21', time: '20:00 - 01:00'),
          const SizedBox(height: 24),

          // Reserve CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.reservationForm),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
              child: const Text('Reservar', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ReservationRow extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  const _ReservationRow({required this.title, required this.date, required this.time});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.lila, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const CircleAvatar(radius: 12, backgroundColor: AppColors.purple, child: Icon(CupertinoIcons.calendar, size: 14, color: Colors.white)),
          const SizedBox(width: 10),
          Expanded(child: Text('$title\n$date  $time')),
          _ChipButton(label: 'Aceptar', onTap: () {}),
          const SizedBox(width: 6),
          _ChipButton(label: 'Cancelar', onTap: () {}),
        ],
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ChipButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), backgroundColor: AppColors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
      child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
    );
  }
}



