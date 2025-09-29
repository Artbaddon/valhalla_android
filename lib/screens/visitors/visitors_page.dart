import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/models/visitor/visitor_model.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/services/visitor_service.dart';
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

  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = Future.value(const <Visitor>[]);
    _searchCtrl.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        setState(() => _query = _searchCtrl.text.trim());
      });
    });
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF2F3FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Detalle de visitante',
          style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w700),
        ),
        content: FutureBuilder<Visitor>(
          future: _service.fetchById(id),
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
            final v = snap.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${v.id}'),
                Text('Nombre: ${v.name}'),
                Text('Documento: ${v.documentNumber}'),
                Text('Anfitrión: ${v.hostName} (#${v.hostId ?? '—'})'),
                Text('Estado: ${v.status ?? '—'}'),
                Text('Entrada: ${_fmtDate(v.enterDate)}'),
                Text('Salida: ${_fmtDate(v.exitDate)}'),
              ],
            );
          },
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
        ],
      ),
    );
  }

  Future<void> _showCreateDialog() async {
    final formKey = GlobalKey<FormState>();
    final hostCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final documentCtrl = TextEditingController();
    bool submitting = false;

    Future<void> submit(StateSetter setStateDialog) async {
      final form = formKey.currentState;
      if (form == null || !form.validate()) return;

      final payload = {
        'host_id': int.parse(hostCtrl.text.trim()),
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
        final message = e.response?.data is Map &&
                (e.response!.data as Map)['error'] is String
            ? (e.response!.data as Map)['error'] as String
            : e.message ?? 'Error al registrar visitante';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text(
                'Registrar visitante',
                style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w700),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: hostCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _fieldDecoration('ID del anfitrión'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requerido';
                          }
                          if (int.tryParse(value.trim()) == null) {
                            return 'Debe ser un número';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: _fieldDecoration('Nombre del visitante'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: documentCtrl,
                        decoration: _fieldDecoration('Documento'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Requerido' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
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

  Future<void> _showStatusDialog(Visitor visitor) async {
    final formKey = GlobalKey<FormState>();
    String status = visitor.status ?? 'pending';
    bool submitting = false;

    Future<void> submit(StateSetter setStateDialog) async {
      final form = formKey.currentState;
      if (form == null || !form.validate()) return;

      final payload = {'status': status};

      setStateDialog(() => submitting = true);
      try {
        await _service.updateStatus(visitor.id, payload);
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estado actualizado')),
        );
        await _refresh();
      } on DioException catch (e) {
        if (!mounted) return;
        final message = e.response?.data is Map &&
                (e.response!.data as Map)['error'] is String
            ? (e.response!.data as Map)['error'] as String
            : e.message ?? 'Error al actualizar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text(
                'Actualizar estado',
                style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w700),
              ),
              content: Form(
                key: formKey,
                child: DropdownButtonFormField<String>(
                  value: status,
                  decoration: _fieldDecoration('Estado'),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pendiente')),
                    DropdownMenuItem(value: 'authorized', child: Text('Autorizado')),
                    DropdownMenuItem(value: 'checked_out', child: Text('Salida registrada')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setStateDialog(() => status = value);
                  },
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    if (_canManage)
                      ElevatedButton.icon(
                        onPressed: _showCreateDialog,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Registrar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
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
                        return DataRow(cells: [
                          DataCell(Text(v.name)),
                          DataCell(Text(v.documentNumber)),
                          DataCell(Text(v.hostName)),
                          DataCell(Text(v.status ?? '—')),
                          DataCell(Text(_fmtDate(v.enterDate))),
                          DataCell(Text(_fmtDate(v.exitDate))),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_red_eye_outlined),
                                tooltip: 'Ver',
                                onPressed: () => _showVisitorDetail(v.id),
                              ),
                              if (_canManage)
                                IconButton(
                                  icon: const Icon(Icons.edit_note_outlined),
                                  tooltip: 'Actualizar estado',
                                  onPressed: () => _showStatusDialog(v),
                                ),
                            ],
                          )),
                        ]);
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
