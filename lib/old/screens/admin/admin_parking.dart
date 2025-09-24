import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:valhalla_android/models/parking/parking_model.dart';
import 'package:valhalla_android/services/parking_service.dart';
import 'dart:async'; // <-- add for debounce

const Color primaryColor = Color.fromRGBO(108, 115, 201, 1);
const Color secondaryColor = Color.fromRGBO(73, 76, 162, 1);
const Color textColor = Color.fromRGBO(243, 243, 255, 1);
const Color accentColor = Color(0xFF6A5ACD);
const Color lightBackground = Color(0xFFE6E6FA);

class ParkingAdminScreen extends StatefulWidget {
  // <-- was StatelessWidget
  const ParkingAdminScreen({super.key});

  @override
  State<ParkingAdminScreen> createState() => _ParkingAdminScreenState();
}

class _ParkingAdminScreenState extends State<ParkingAdminScreen> {
  final _service = ParkingService();
  late Future<List<Parking>> _future;

  // Search/filter state
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String? _typeFilter; // 'resident' | 'visitor' | null
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchAll();

    _searchCtrl.addListener(() {
      // debounce to avoid too many rebuilds
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        setState(() => _query = _searchCtrl.text.trim());
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // Filter logic (query + type)
  List<Parking> _applyFilters(List<Parking> items) {
    Iterable<Parking> out = items;

    if (_typeFilter != null) {
      final isRes = _typeFilter == 'resident';
      out = out.where((p) {
        final t = (p.parkingType).toLowerCase();
        return isRes ? t.contains('reg') : t.contains('vis');
      });
    }

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      out = out.where((p) {
        return p.number.toLowerCase().contains(q) ||
            p.parkingType.toLowerCase().contains(q) ||
            p.vehicleType.toLowerCase().contains(q) ||
            p.status.toLowerCase().contains(q) ||
            p.id.toString() == q;
      });
    }

    return out.toList();
  }

  void _openFilters() async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Filtrar por tipo')),
              RadioListTile<String?>(
                value: null,
                groupValue: _typeFilter,
                onChanged: (v) => Navigator.pop(ctx, v),
                title: const Text('Todos'),
              ),
              RadioListTile<String?>(
                value: 'resident',
                groupValue: _typeFilter,
                onChanged: (v) => Navigator.pop(ctx, v),
                title: const Text('Residentes'),
              ),
              RadioListTile<String?>(
                value: 'visitor',
                groupValue: _typeFilter,
                onChanged: (v) => Navigator.pop(ctx, v),
                title: const Text('Visitantes'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (!mounted) return;
    if (selected != _typeFilter) {
      setState(() => _typeFilter = selected);
    }
  }

  // 7) show a dialog that fetches ONE by id and renders it
  void _showParkingDetail(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Detalle del parqueadero'),
          content: FutureBuilder<Parking>(
            future: ParkingService().fetchById(id),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) {
                return Text('Error: ${snap.error}');
              }
              final p = snap.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${p.id}'),
                  Text('Número: ${p.number}'),
                  Text('Tipo: ${p.parkingType}'),
                  Text('Vehículo: ${p.vehicleType}'),
                  Text('Estado: ${p.status}'),
                  Text('Usuario: ${p.userId}'),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildParkingSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: secondaryColor),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: items),
        ),
      ],
    );
  }

  Widget _buildParkingCard({
    required String title,
    required String subtitle,
    required bool isResident,
    required VoidCallback onView,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                child: Icon(CupertinoIcons.car, size: 100, color: primaryColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isResident ? 'Residente' : 'Visitante',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: onView,
                        child: const Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye_outlined,
                              color: accentColor,
                              size: 20,
                            ),
                            SizedBox(width: 4),
                            Text('Ver', style: TextStyle(color: accentColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final future = _future; // unchanged fetch; we filter client-side
    return Scaffold(
      backgroundColor: lightBackground,
      body: FutureBuilder<List<Parking>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // 1) get data
          final items = snapshot.data ?? const <Parking>[];
          // 2) apply search + filters
          final visible = _applyFilters(items);

          // 3) group visible items
          String _categoryTitle(String raw) {
            final v = (raw).toLowerCase();
            if (v.contains('reg') || v.contains('res'))
              return 'Parqueaderos de Residentes';
            if (v.contains('vis')) return 'Parqueaderos de Visitantes';
            return 'Otros parqueaderos';
          }

          final Map<String, List<Parking>> groups = {};
          for (final p in visible) {
            final key = _categoryTitle(p.parkingType);
            groups.putIfAbsent(key, () => []).add(p);
          }

          final desiredOrder = <String>[
            'Parqueaderos de Residentes',
            'Parqueaderos de Visitantes',
          ];
          final titles = [
            ...desiredOrder.where(groups.keys.contains),
            ...groups.keys.where((k) => !desiredOrder.contains(k)).toList()
              ..sort(),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          // <-- remove const, wire controller
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Buscar...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            suffixIcon: (_query.isEmpty)
                                ? null
                                : IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      // listener will set _query and rebuild
                                    },
                                  ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _openFilters, // <-- opens bottom sheet
                      icon: const Icon(Icons.filter_list, color: textColor),
                      label: Text(
                        _typeFilter == null
                            ? 'Filtros'
                            : (_typeFilter == 'resident'
                                  ? 'Residentes'
                                  : 'Visitantes'),
                        style: const TextStyle(color: textColor),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 40),
                      ),
                    ),
                  ],
                ),
                for (final title in titles) ...[
                  _buildParkingSection(
                    title: title,
                    items: groups[title]!.map((p) {
                      return _buildParkingCard(
                        title: 'Parqueadero ${p.number}',
                        subtitle: '${p.vehicleType} • ${p.status}',
                        isResident: title.contains('Residentes'),
                        onView: () => _showParkingDetail(context, p.id),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
