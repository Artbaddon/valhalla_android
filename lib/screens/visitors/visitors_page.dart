import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/models/visitor/visitor_model.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/services/visitor_service.dart';
import 'package:valhalla_android/services/owner_service.dart';
import 'package:valhalla_android/utils/navigation_config.dart';

const Color secondaryColor = Color.fromRGBO(73, 76, 162, 1);
const Color accentColor = Color(0xFF6A5ACD);
const Color lightBackground = Color(0xFFE6E6FA);

class AdminVisitorsPage extends StatefulWidget {
  const AdminVisitorsPage({super.key});

  @override
  State<AdminVisitorsPage> createState() => _AdminVisitorsPageState();
}

class _AdminVisitorsPageState extends State<AdminVisitorsPage> {
  final _service = VisitorService();
  late Future<List<Visitor>> _future;
  UserRole? _role;
  int? _ownerId;
  List<Map<String, dynamic>> owners = [];
  bool loadingOwners = false;
  String? selectedOwnerId;

  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadOwners();
    _future = Future.value(const <Visitor>[]);
    _searchCtrl.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        setState(() => _query = _searchCtrl.text.trim());
      });
    });
  }

  Future<void> _loadOwners() async {
    if (loadingOwners) return;
    if (!mounted) return;

    setState(() {
      loadingOwners = true;
    });

    try {
      final ownerService = OwnerService();
      final response = await ownerService.getAllOwners();

      if (!mounted) return;

      // ✅ SIMPLE - Eliminar duplicados por ID
      final seenIds = <int>{};
      final ownersList = <Map<String, dynamic>>[];

      for (final owner in response) {
        if (!seenIds.contains(owner.ownerId)) {
          seenIds.add(owner.ownerId);
          ownersList.add({'id': owner.ownerId, 'name': owner.fullName});
        }
      }

      setState(() {
        owners = ownersList;
        loadingOwners = false;
      });
    } catch (e) {
      print('Error: $e');
      if (!mounted) return;
      setState(() => loadingOwners = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = Provider.of<AuthProvider>(context);
    final nextRole = auth.role;
    final nextOwnerId = auth.user?.id;
    if (_role != nextRole || _ownerId != nextOwnerId) {
      _role = nextRole;
      _ownerId = nextOwnerId;
      _future = _loadVisitors();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<List<Visitor>> _loadVisitors() async {
    try {
      if (_role == UserRole.owner && _ownerId != null) {
        return await _service.fetchForOwner(_ownerId!);
      }
      return await _service.fetchAll();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return const <Visitor>[];
      }
      rethrow;
    }
  }

  Future<void> _refresh() async {
    final next = _loadVisitors();
    setState(() => _future = next);
    await next;
  }

  bool get _canManage => _role == UserRole.admin || _role == UserRole.security;

  bool get _isOwner => _role == UserRole.owner;

  List<Visitor> _applyFilters(List<Visitor> items) {
    if (_query.isEmpty) return items;
    final q = _query.toLowerCase();
    return items.where((v) {
      return v.name.toLowerCase().contains(q) ||
          v.documentNumber.toLowerCase().contains(q) ||
          v.hostName.toLowerCase().contains(q) ||
          (v.hostId?.toString() ?? '').contains(q);
    }).toList();
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '—';
    final d = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
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

  void _showVisitorDetail(int id) {
    // Primero obtenemos el visitor ANTES de mostrar el diálogo
    final visitorFuture = _service.fetchById(id);

    // Usamos showDialog directamente sin StatefulBuilder innecesario
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<Visitor>(
          future: visitorFuture,
          builder: (context, snapshot) {
            Widget content;

            if (snapshot.connectionState == ConnectionState.waiting) {
              content = const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              content = Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              content = const Text('No se encontró el visitante');
            } else {
              final v = snapshot.data!;
              content = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre: ${v.name}'),
                  const SizedBox(height: 8),
                  Text('Documento: ${v.documentNumber}'),
                  const SizedBox(height: 8),
                  Text('Anfitrión: ${v.hostName} (#${v.hostId ?? '—'})'),
                  const SizedBox(height: 8),
                  Text('Estado: ${v.status ?? '—'}'),
                  const SizedBox(height: 8),
                  Text('Entrada: ${_fmtDate(v.enterDate)}'),
                  const SizedBox(height: 8),
                  Text('Salida: ${_fmtDate(v.exitDate)}'),
                ],
              );
            }

            return AlertDialog(
              backgroundColor: const Color(0xFFF2F3FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'Detalle de visitante',
                style: TextStyle(
                  color: secondaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: content,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: secondaryColor,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showCreateDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final documentCtrl = TextEditingController();
    bool submitting = false;

    Future<void> submit(StateSetter setStateDialog) async {
      final form = formKey.currentState;
      if (form == null || !form.validate()) return;

      if (selectedOwnerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor seleccione un propietario')),
        );
        return;
      }

      final payload = {
        'host_id': int.parse(selectedOwnerId!),
        'visitor_name': nameCtrl.text.trim(),
        'document_number': documentCtrl.text.trim(),
      };

      setStateDialog(() => submitting = true);
      try {
        await _service.registerVisitor(payload);
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visitante registrado correctamente')),
        );
        await _refresh();
      } on DioException catch (e) {
        if (!mounted) return;
        final message =
            e.response?.data is Map &&
                (e.response!.data as Map)['error'] is String
            ? (e.response!.data as Map)['error'] as String
            : e.message ?? 'Error al registrar visitante';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } finally {
        if (mounted) {
          setStateDialog(() => submitting = false);
        }
      }
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF2F3FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'Registrar visitante',
                style: TextStyle(
                  color: secondaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedOwnerId,
                        decoration: _fieldDecoration(
                          'Seleccione un propietario',
                        ),
                        validator: (value) =>
                            value == null ? 'Requerido' : null,
                        items: [
                          // Estado de carga
                          if (loadingOwners)
                            const DropdownMenuItem(
                              value: null,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Cargando propietarios...'),
                                ],
                              ),
                            ),

                          // Estado vacío (después de cargar)
                          if (!loadingOwners && owners.isEmpty)
                            const DropdownMenuItem(
                              value: null,
                              child: Text(
                                'No hay propietarios disponibles',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),

                          // Estado cargado - mostrar owners
                          if (!loadingOwners && owners.isNotEmpty)
                            ...owners.map((owner) {
                              return DropdownMenuItem(
                                value: owner['id'].toString(),
                                child: Text(
                                  owner['name'] ?? 'Sin nombre',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                        ],
                        onChanged: loadingOwners || owners.isEmpty
                            ? null
                            : (value) {
                                setState(() {
                                  selectedOwnerId = value;
                                });
                              },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: _fieldDecoration('Nombre del visitante'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: documentCtrl,
                        decoration: _fieldDecoration('Documento'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                TextButton(
                  onPressed: submitting ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: secondaryColor,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Cancelar'),
                ),
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
                  onPressed: submitting ? null : () => submit(setStateDialog),
                  child: submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      body: FutureBuilder<List<Visitor>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? const <Visitor>[];
          final visible = _applyFilters(items);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Visitantes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor,
                      ),
                    ),
                    if (_canManage)
                      ElevatedButton.icon(
                        onPressed: _showCreateDialog,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Registrar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, documento o anfitrión',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: (_query.isEmpty)
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () => _searchCtrl.clear(),
                            ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
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
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Nombre')),
                        DataColumn(label: Text('Documento')),
                        DataColumn(label: Text('Anfitrión')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Entrada')),
                        DataColumn(label: Text('Salida')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: visible.map((v) {
                        return DataRow(
                          cells: [
                            DataCell(Text(v.name)),
                            DataCell(Text(v.documentNumber)),
                            DataCell(Text(v.hostName)),
                            DataCell(Text(v.status ?? '—')),
                            DataCell(Text(_fmtDate(v.enterDate))),
                            DataCell(Text(_fmtDate(v.exitDate))),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_red_eye_outlined,
                                    ),
                                    tooltip: 'Ver',
                                    onPressed: () => _showVisitorDetail(v.id),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        _isOwner
                            ? 'No tienes visitantes registrados.'
                            : 'No hay visitantes disponibles.',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
