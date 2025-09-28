import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:valhalla_android/models/parking/parking_model.dart';
import 'package:valhalla_android/services/parking_service.dart';
import 'dart:async'; // <-- add for debounce
import 'package:provider/provider.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/utils/navigation_config.dart';

const Color primaryColor = Color.fromRGBO(108, 115, 201, 1);
const Color secondaryColor = Color.fromRGBO(73, 76, 162, 1);
const Color textColor = Color.fromRGBO(243, 243, 255, 1);
const Color accentColor = Color(0xFF6A5ACD);
const Color lightBackground = Color(0xFFE6E6FA);

class ParkingScreen extends StatefulWidget {
  // <-- was StatelessWidget
  const ParkingScreen({super.key});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
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

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: secondaryColor),
      filled: true,
      fillColor: Colors.white,
      prefixIconColor: secondaryColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: secondaryColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: accentColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: secondaryColor.withOpacity(0.3)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _parkingForm(BuildContext context, String mode, {Parking? parking}) {
    final isEdit = mode == 'edit';
    final isView = mode == 'view';
    final numberCtrl = TextEditingController(text: parking?.number ?? '');
    final typeCtrl = TextEditingController(text: parking?.parkingType ?? '');
    final vehicleCtrl = TextEditingController(text: parking?.vehicleType ?? '');
    final statusCtrl = TextEditingController(text: parking?.status ?? '');
    final userCtrl = TextEditingController(
      text: parking != null ? (parking.userId?.toString() ?? '') : '',
    );
    Map<int, String> statusOptions = {
      1: 'Disponible',
      2: 'Ocupado',
      3: 'Reservado',
    };
    Map<int, String> typeOptions = {1: 'Residente', 2: 'Visitante'};
    return AlertDialog(
      backgroundColor: const Color(0xFFF2F3FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            switch (mode) {
              'add' => 'Añadir Parqueadero',
              'edit' => 'Editar Parqueadero',
              _ => 'Detalle de Parqueadero',
            },
            style: const TextStyle(
              color: secondaryColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: secondaryColor),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numberCtrl,
              enabled: !isView,
              decoration: _fieldDecoration('Número'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: typeCtrl.text.isNotEmpty ? typeCtrl.text : null,
              decoration: _fieldDecoration('Tipo de Parqueadero'),
              items: [
                DropdownMenuItem(value: 'Residente', child: Text('Residente')),
                DropdownMenuItem(value: 'Visitante', child: Text('Visitante')),
              ],
              onChanged: isView
                  ? null
                  : (value) {
                      typeCtrl.text = value ?? '';
                    },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: statusCtrl.text.isNotEmpty ? statusCtrl.text : null,
              decoration: _fieldDecoration('Estado'),
              items: [
                DropdownMenuItem(
                  value: 'Disponible',
                  child: Text('Disponible'),
                ),
                DropdownMenuItem(value: 'Ocupado', child: Text('Ocupado')),
                DropdownMenuItem(value: 'Reservado', child: Text('Reservado')),
              ],
              onChanged: isView
                  ? null
                  : (value) {
                      statusCtrl.text = value ?? '';
                    },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: vehicleCtrl,
              enabled: !isView,
              decoration: _fieldDecoration('Tipo de Vehículo'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: statusCtrl,
              enabled: !isView,
              decoration: _fieldDecoration('Estado'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: userCtrl,
              enabled: !isView,
              decoration: _fieldDecoration('ID de Usuario (opcional)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: secondaryColor,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          child: const Text('Cerrar'),
        ),
        if (!isView)
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () async {
              final payload = Parking(
                id: parking?.id ?? 0,
                number: numberCtrl.text.trim(),
                parkingType: typeCtrl.text.trim(),
                vehicleType: vehicleCtrl.text.trim(),
                status: statusCtrl.text.trim(),
                userId: userCtrl.text.trim().isEmpty
                    ? null
                    : int.tryParse(userCtrl.text.trim()),
              );
              try {
                if (isEdit) {
                  await _service.update(payload.id, payload.toJson());
                } else {
                  await _service.create(payload.toJson());
                }
                if (!mounted) return;
                Navigator.pop(context);
                setState(() {
                  _future = _service.fetchAll();
                });
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(isEdit ? 'Guardar' : 'Añadir'),
          ),
      ],
    );
  }

Future<void> _showParkingForm(String mode, {Parking? parking}) {
  return showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      final isEdit = mode == 'edit';
      final isView = mode == 'view';
      final numberCtrl = TextEditingController(text: parking?.number ?? '');
      final userCtrl = TextEditingController(
        text: parking?.userId?.toString() ?? '',
      );

      const typeOptions = {'1': 'Residente', '2': 'Visitante'};
      const vehicleOptions = {'1': 'Automóvil', '2': 'Moto'};
      const statusOptions = {
        '1': 'Disponible',
        '2': 'Ocupado',
        '3': 'Reservado',
      };

      // Map parking values to dropdown keys
      String? typeValue;
      String? vehicleValue;
      String? statusValue;

      if (parking != null) {
        // Type mapping
        final parkingTypeLower = parking.parkingType.toLowerCase();
        if (parkingTypeLower.contains('residente') || parkingTypeLower.contains('resident')) {
          typeValue = '1';
        } else if (parkingTypeLower.contains('visitante') || parkingTypeLower.contains('visitor')) {
          typeValue = '2';
        }

        // Vehicle mapping
        final vehicleTypeLower = parking.vehicleType.toLowerCase();
        if (vehicleTypeLower.contains('auto') || vehicleTypeLower.contains('car')) {
          vehicleValue = '1';
        } else if (vehicleTypeLower.contains('moto') || vehicleTypeLower.contains('motorcycle')) {
          vehicleValue = '2';
        }

        // Status mapping
        final statusLower = parking.status.toLowerCase();
        if (statusLower.contains('disponible') || statusLower.contains('available')) {
          statusValue = '1';
        } else if (statusLower.contains('ocupado') || statusLower.contains('occupied')) {
          statusValue = '2';
        } else if (statusLower.contains('reservado') || statusLower.contains('reserved')) {
          statusValue = '3';
        }
      }

      return StatefulBuilder(
        builder: (ctx, setInnerState) {
          final formKey = GlobalKey<FormState>();
          return AlertDialog(
            backgroundColor: const Color(0xFFF2F3FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  switch (mode) {
                    'add' => 'Añadir Parqueadero',
                    'edit' => 'Editar Parqueadero',
                    _ => 'Detalle de Parqueadero',
                  },
                  style: const TextStyle(
                    color: secondaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: secondaryColor),
              ],
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: numberCtrl,
                    enabled: !isView,
                    decoration: _fieldDecoration('Número'),
                    validator: isView
                        ? null
                        : (value) => (value == null || value.trim().isEmpty)
                              ? 'Ingrese el número'
                              : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: typeValue,
                    decoration: _fieldDecoration('Tipo de Parqueadero'),
                    items: typeOptions.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                        )
                        .toList(),
                    onChanged: isView
                        ? null
                        : (value) => setInnerState(() => typeValue = value),
                    validator: isView || typeOptions.isEmpty
                        ? null
                        : (value) =>
                              value == null ? 'Seleccione un tipo' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: vehicleValue,
                    decoration: _fieldDecoration('Tipo de Vehículo'),
                    items: vehicleOptions.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                        )
                        .toList(),
                    onChanged: isView
                        ? null
                        : (value) =>
                              setInnerState(() => vehicleValue = value),
                    validator: isView
                        ? null
                        : (value) => value == null
                              ? 'Seleccione el tipo de vehículo'
                              : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: statusValue,
                    decoration: _fieldDecoration('Estado'),
                    items: statusOptions.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                        )
                        .toList(),
                    onChanged: isView
                        ? null
                        : (value) => setInnerState(() => statusValue = value),
                    validator: isView
                        ? null
                        : (value) =>
                              value == null ? 'Seleccione el estado' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: userCtrl,
                    enabled: !isView,
                    decoration: _fieldDecoration('ID de Usuario (opcional)'),
                    keyboardType: TextInputType.number,
                    validator: isView
                        ? null
                        : (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null;
                            }
                            return int.tryParse(value.trim()) == null
                                ? 'Ingrese un número válido'
                                : null;
                          },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cerrar'),
              ),
              if (!isView)
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () async {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    // Create payload with proper API format (all as numbers)
                    final apiPayload = {
                      'number': numberCtrl.text.trim(),
                      'type_id': int.parse(typeValue ?? '1'), // Send as number
                      'vehicle_type_id': int.parse(vehicleValue ?? '1'), // Send as number
                      'status_id': int.parse(statusValue ?? '1'), // Send as number
                      if (userCtrl.text.trim().isNotEmpty) 
                        'user_id': int.parse(userCtrl.text.trim()),
                    };
                    
                    try {
                      if (isEdit) {
                        await _service.update(parking!.id, apiPayload);
                      } else {
                        await _service.create(apiPayload);
                      }
                      if (!mounted) return;
                      Navigator.pop(context);
                      setState(() {
                        _future = _service.fetchAll();
                      });
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  child: Text(isEdit ? 'Guardar' : 'Añadir'),
                ),
            ],
          );
        },
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
    required Parking parking,
    required String title,
    required String subtitle,
    required bool isResident,
    required bool isAdmin,
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
                          ],
                        ),
                      ),
                      if (isAdmin) ...[
                        GestureDetector(
                          onTap: () => _showParkingForm('edit', parking: parking),
                          child: const Row(
                            children: [
                              Icon(Icons.edit, color: accentColor, size: 20),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Confirmar eliminación'),
                                content: const Text(
                                  '¿Estás seguro de que deseas eliminar este parqueadero?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              try {
                                await _service.delete(parking.id);
                                if (!mounted) return;
                                setState(() {
                                  _future = _service.fetchAll();
                                });
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                            ],
                          ),
                        ),
                      ],
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
    final future = _future;
    final isAdmin = context.watch<AuthProvider>().role == UserRole.admin;
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text(
                        'Gestión Parqueaderos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor,
                        ),
                      ),
                      const Spacer(),
                      if (isAdmin)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Añadir',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            minimumSize: const Size(0, 40),
                          ),
                          onPressed: () => _showParkingForm('add'),
                        ),
                    ],
                  ),
                ),
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
                ...titles.map(
                  (title) => _buildParkingSection(
                    title: title,
                    items: groups[title]!.map((p) {
                      return _buildParkingCard(
                        parking: p,
                        title: 'Parqueadero ${p.number}',
                        subtitle: '${p.vehicleType} • ${p.status}',
                        isResident: title.contains('Residentes'),
                        isAdmin: isAdmin,
                        onView: () => _showParkingForm('view', parking: p),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
