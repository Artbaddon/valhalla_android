import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:valhalla_android/utils/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:valhalla_android/models/reservation/reservation_model.dart';
import 'package:valhalla_android/services/reservation_service.dart';

// Reservations home: calendar, small reservations list, CTA button
class ReservationsHomePage extends StatefulWidget {
  const ReservationsHomePage({super.key});
  @override
  State<ReservationsHomePage> createState() => _ReservationsHomePageState();
}

class _ReservationsHomePageState extends State<ReservationsHomePage> {
  final _reservationService = ReservationService();
  late Future<List<Reservation>> _futureReservations;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _futureReservations = _reservationService.fetchAll();
  }

  Future<void> refresh() async {
    setState(() {
      _futureReservations = _reservationService.fetchAll();
    });
    await _futureReservations;
  }

  List<Reservation> _forDay(List<Reservation> items, DateTime day) {
    bool sameDay(DateTime? a, DateTime b) =>
        a != null && a.year == b.year && a.month == b.month && a.day == b.day;
    return items.where((r) => sameDay(r.startTime, day)).toList();
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  String _fmtRange(Reservation r) {
    final s = r.startTime?.toLocal();
    final e = r.endTime?.toLocal();
    if (s == null || e == null) return '—';
    return '${_two(s.hour)}:${_two(s.minute)} - ${_two(e.hour)}:${_two(e.minute)}';
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '—';
    final local = value.toLocal();
    return '${local.year}-${_two(local.month)}-${_two(local.day)} ${_two(local.hour)}:${_two(local.minute)}';
  }

  String _formatDay(DateTime value) {
    final local = value.toLocal();
    return '${local.year}-${_two(local.month)}-${_two(local.day)}';
  }

  String _valueOrDash(String? value) {
    if (value == null) return '—';
    final trimmed = value.trim();
    return trimmed.isEmpty ? '—' : trimmed;
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppColors.black, height: 1.3),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  void _showReservationDetail(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.lila,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Detalle de reserva',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w700),
        ),
        content: Theme(
          data: Theme.of(context).copyWith(
            textTheme: Theme.of(context)
                .textTheme
                .apply(bodyColor: AppColors.black),
          ),
          child: FutureBuilder<Reservation>(
            future: _reservationService.fetchById(id),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) return Text('Error: ${snap.error}');
              final r = snap.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('ID', '${r.id}'),
                  _detailRow('Tipo', _valueOrDash(r.typeName)),
                  _detailRow('Estado', _valueOrDash(r.statusName)),
                  _detailRow('Inicio', _formatDateTime(r.startTime)),
                  _detailRow('Fin', _formatDateTime(r.endTime)),
                  _detailRow('Propietario', _valueOrDash(r.ownerName)),
                  _detailRow('Descripción', _valueOrDash(r.description)),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.purple),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay ?? _focusedDay;

    DateTime _norm(DateTime d) => DateTime(d.year, d.month, d.day);

    Widget _buildCalendar(Map<DateTime, int> counts) {
      Widget dayCell(DateTime day, {bool isSelected = false}) {
        final has = (counts[_norm(day)] ?? 0) > 0;
        final borderColor = has ? Colors.red : Colors.green;
        final bg = isSelected ? AppColors.lila : Colors.transparent;
        return Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
            shape: BoxShape.circle,
          ),
          child: Text('${day.day}', style: const TextStyle(fontSize: 12, color: AppColors.black),),
        );
      }

      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
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
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) => dayCell(day),
            selectedBuilder: (context, day, focusedDay) =>
                dayCell(day, isSelected: true),
            todayBuilder: (context, day, focusedDay) => dayCell(day),
            outsideBuilder: (context, day, focusedDay) =>
                Opacity(opacity: 0.5, child: dayCell(day)),
          ),
          ),
        ),
      );
    }

    return FutureBuilder<List<Reservation>>(
      future: _futureReservations,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final all = snapshot.data ?? const <Reservation>[];
        final counts = <DateTime, int>{};
        for (final r in all) {
          final d = r.startTime;
          if (d != null) {
            final k = _norm(d.toLocal());
            counts[k] = (counts[k] ?? 0) + 1;
          }
        }

        final itemsOfDay = _forDay(all, selected);

        return RefreshIndicator(
          onRefresh: refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCalendar(counts),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 8),
                  child: Text(
                    'Reservas del día seleccionado',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (itemsOfDay.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No hay reservas para este día'),
                  )
                else
                  Column(
                    children: itemsOfDay.map((r) {
            final date = _formatDay(selected);
                      final title =
                          '${r.typeName.isNotEmpty ? r.typeName : 'Zona'} • ${r.ownerName.isNotEmpty ? r.ownerName : '—'}';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _showReservationDetail(context, r.id),
                            child: _ReservationRow(
                              title: title,
                              date: date,
                              time: _fmtRange(r),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 8),
                  child: Text(
                    'Todas las reservas',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Column(
                  children: all.map((r) {
                    final s = r.startTime?.toLocal();
          final date = s == null ? '—' : _formatDay(s);
                    final title =
                        '${r.typeName.isNotEmpty ? r.typeName : 'Zona'} • ${r.ownerName.isNotEmpty ? r.ownerName : '—'}';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _showReservationDetail(context, r.id),
                          child: _ReservationRow(
                            title: title,
                            date: date,
                            time: _fmtRange(r),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push(AppRoutes.reservationForm),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Reservar',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReservationRow extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  const _ReservationRow({
    required this.title,
    required this.date,
    required this.time,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lila,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.purple,
            child: Icon(CupertinoIcons.calendar, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text('$title\n$date  $time', style: const TextStyle(fontSize: 12, color: Colors.black87))),
          const Icon(CupertinoIcons.chevron_right, size: 16, color: Colors.black54),
        ],
      ),
    );
  }
}