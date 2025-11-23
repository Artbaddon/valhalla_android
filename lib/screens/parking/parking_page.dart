import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:valhalla_android/models/parking/parking_model.dart';
import 'package:valhalla_android/models/owner/owner_model.dart';
import 'package:valhalla_android/services/parking_service.dart';
import 'package:valhalla_android/services/owner_service.dart';
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
  List<Owner> _owners = [];
  List<ParkingType> _parkingTypes = [];
  List<ParkingStatus> _parkingStatuses = [];
  bool _loadingOwners = false;
  bool _loadingTypes = false;
  bool _loadingStatuses = false;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchAll();
    _loadOwners();
    _loadParkingTypes();
    _loadParkingStatuses();

    _searchCtrl.addListener(() {
      // debounce to avoid too many rebuilds
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        setState(() => _query = _searchCtrl.text.trim());
      });
    });
  }

  Future<void> _loadOwners() async {
    if (_loadingOwners) return;

    setState(() {
      _loadingOwners = true;
    });

    try {
      final ownerService = OwnerService();
      final owners = await ownerService.getAllOwners();
      setState(() {
        _owners = owners;
        _loadingOwners = false;
      });
    } catch (e) {
      setState(() {
        _loadingOwners = false;
      });
      print('Error loading owners: $e');
    }
  }

  Future<void> _loadParkingTypes() async {
    if (_loadingTypes) return;
    setState(() => _loadingTypes = true);
    try {
      final types = await _service.getParkingTypes();
      setState(() => _parkingTypes = types);
    } catch (e) {
      print('Error loading parking types: $e');
    } finally {
      setState(() => _loadingTypes = false);
    }
  }

  Future<void> _loadParkingStatuses() async {
    if (_loadingStatuses) return;
    setState(() => _loadingStatuses = true);
    try {
      final statuses = await _service.getParkingStatuses();
      setState(() => _parkingStatuses = statuses);
    } catch (e) {
      print('Error loading parking statuses: $e');
    } finally {
      setState(() => _loadingStatuses = false);
    }
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

  Future<void> _showParkingForm(String mode, {Parking? parking}) {
    return showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final isEdit = mode == 'edit';
        final isView = mode == 'view';
        final isAdd = mode == 'add';
        final numberCtrl = TextEditingController(text: parking?.number ?? '');

        // ✅ CORREGIR: orElse debe retornar Owner, usar try-catch en su lugar
        Owner? findOwner() {
          if (parking != null && (isEdit || isView) && parking.userId != null) {
            try {
              return _owners.firstWhere(
                (owner) => owner.userFkId == parking.userId,
              );
            } catch (e) {
              return null;
            }
          }
          return null;
        }

        final typeValueNotifier = ValueNotifier<String?>(
          parking != null
              ? _findParkingTypeId(parking.parkingType)
              : (_parkingTypes.isNotEmpty
                    ? _parkingTypes.first.id.toString()
                    : '1'),
        );

        final statusValueNotifier = ValueNotifier<String?>(
          parking != null
              ? _findParkingStatusId(parking.status)
              : (_parkingStatuses.isNotEmpty
                    ? _parkingStatuses.first.id.toString()
                    : '1'),
        );

        final selectedOwnerNotifier = ValueNotifier<Owner?>(findOwner());

        return StatefulBuilder(
          builder: (ctx, setInnerState) {
            final formKey = GlobalKey<FormState>();

            // ✅ Cargar owners si es necesario
            if ((isEdit || isView) && _owners.isEmpty && !_loadingOwners) {
              _loadOwners();
            }

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

                    // ✅ DROPDOWN DE TIPOS CON ValueListenableBuilder
                    ValueListenableBuilder<String?>(
                      valueListenable: typeValueNotifier,
                      builder: (context, typeValue, child) {
                        return DropdownButtonFormField<String>(
                          value: typeValue,
                          decoration: _fieldDecoration('Tipo de Parqueadero'),
                          items: _parkingTypes.map((type) {
                            return DropdownMenuItem(
                              value: type.id.toString(),
                              child: Text(type.name),
                            );
                          }).toList(),
                          onChanged: isView
                              ? null
                              : (value) {
                                  typeValueNotifier.value = value;
                                  setInnerState(() {}); // Forzar rebuild
                                },
                          validator: isView || _parkingTypes.isEmpty
                              ? null
                              : (value) =>
                                    value == null ? 'Seleccione un tipo' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // ✅ DROPDOWN DE ESTADOS CON ValueListenableBuilder
                    ValueListenableBuilder<String?>(
                      valueListenable: statusValueNotifier,
                      builder: (context, statusValue, child) {
                        return DropdownButtonFormField<String>(
                          value: statusValue,
                          decoration: _fieldDecoration('Estado'),
                          items: _parkingStatuses.map((status) {
                            return DropdownMenuItem(
                              value: status.id.toString(),
                              child: Text(status.name),
                            );
                          }).toList(),
                          onChanged: isView
                              ? null
                              : (value) {
                                  statusValueNotifier.value = value;
                                  setInnerState(() {}); // Forzar rebuild
                                },
                          validator: isView
                              ? null
                              : (value) => value == null
                                    ? 'Seleccione el estado'
                                    : null,
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    if (isEdit || isView) ...[
                      if (_loadingOwners && isEdit) ...[
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        const Text('Cargando propietarios...'),
                      ] else
                        ValueListenableBuilder<Owner?>(
                          valueListenable: selectedOwnerNotifier,
                          builder: (context, selectedOwner, child) {
                            return isView
                                ? TextFormField(
                                    enabled: false,
                                    decoration: _fieldDecoration('Propietario'),
                                    initialValue: selectedOwner != null
                                        ? selectedOwner.fullName
                                        : 'Ninguno',
                                  )
                                : DropdownButtonFormField<Owner?>(
                                    value: selectedOwner,
                                    decoration: _fieldDecoration(
                                      'Propietario (opcional)',
                                    ),
                                    items: [
                                      const DropdownMenuItem<Owner?>(
                                        value: null,
                                        child: Text('Ninguno'),
                                      ),
                                      ..._owners.map((owner) {
                                        return DropdownMenuItem<Owner>(
                                          value: owner,
                                          child: Text(
                                            owner.fullName,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (Owner? newOwner) {
                                      selectedOwnerNotifier.value = newOwner;
                                      setInnerState(() {}); // Forzar rebuild
                                    },
                                    isExpanded: true,
                                  );
                          },
                        ),
                    ] else if (isAdd) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'El propietario se asignará después de crear el parqueadero',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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

                      final apiPayload = {
                        'number': numberCtrl.text.trim(),
                        'type_id': int.parse(typeValueNotifier.value ?? '1'),
                        'status_id': int.parse(
                          statusValueNotifier.value ?? '1',
                        ),
                        if (isEdit && selectedOwnerNotifier.value != null)
                          'user_id': selectedOwnerNotifier.value!.userFkId,
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

  String _findParkingTypeId(String parkingTypeName) {
    if (_parkingTypes.isEmpty) return '1';

    try {
      final type = _parkingTypes.firstWhere(
        (type) => type.name.toLowerCase() == parkingTypeName.toLowerCase(),
        orElse: () => _parkingTypes.first,
      );
      return type.id.toString();
    } catch (e) {
      return _parkingTypes.first.id.toString();
    }
  }

  String _findParkingStatusId(String statusName) {
    if (_parkingStatuses.isEmpty) return '1';

    try {
      final status = _parkingStatuses.firstWhere(
        (status) => status.name.toLowerCase() == statusName.toLowerCase(),
        orElse: () => _parkingStatuses.first,
      );
      return status.id.toString();
    } catch (e) {
      return _parkingStatuses.first.id.toString();
    }
  }

  // ✅ Agrega este método helper si no lo tienes
  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
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
                          onTap: () =>
                              _showParkingForm('edit', parking: parking),
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
    final isOwner = context.watch<AuthProvider>().role == UserRole.owner;

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
                      if (isOwner)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Reservar',
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
