import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/models/packages/packages_model.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/services/packages_service.dart';
import 'package:valhalla_android/utils/navigation_config.dart';

const Color secondaryColor = Color.fromRGBO(73, 76, 162, 1);
const Color accentColor = Color(0xFF6A5ACD);
const Color textColor = Color.fromRGBO(243, 243, 255, 1);
const Color lightBackground = Color(0xFFE6E6FA);

class PackagesAdminScreen extends StatefulWidget {
  const PackagesAdminScreen({super.key});

  @override
  State<PackagesAdminScreen> createState() => _PackagesAdminScreenState();
}

class _PackagesAdminScreenState extends State<PackagesAdminScreen> {
  final _service = PackagesService();
  late Future<List<Packages>> _future;
  UserRole? _role;
  int? _ownerId;

  // search/filter
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _query = '';
  String? _typeFilter; // null = all
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _future = Future.value(const <Packages>[]);
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
      _future = _loadPackages();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<List<Packages>> _loadPackages() async {
    try {
      if (_role == UserRole.owner && _ownerId != null) {
        return await _service.fetchForOwner(_ownerId!);
      }
      return await _service.fetchAll();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return const <Packages>[];
      }
      rethrow;
    }
  }

  Future<void> _refresh() async {
    final next = _loadPackages();
    setState(() => _future = next);
    await next;
  }

  bool get _canManagePackages =>
      _role == UserRole.security || _role == UserRole.admin;

  bool get _isOwner => _role == UserRole.owner;

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

  List<Packages> _applyFilters(List<Packages> items) {
    Iterable<Packages> out = items;

    if (_typeFilter != null && _typeFilter!.isNotEmpty) {
      final f = _typeFilter!.toLowerCase();
      out = out.where((p) => (p.packageType).toLowerCase() == f);
    }

    if (_statusFilter != null && _statusFilter!.isNotEmpty) {
      final f = _statusFilter!.toLowerCase();
      out = out.where((p) => (p.status ?? '').toLowerCase() == f);
    }

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      out = out.where((p) {
        return p.packageId.toLowerCase().contains(q) ||
               p.packageType.toLowerCase().contains(q) ||
               p.recipientApartment.toLowerCase().contains(q) ||
               p.recipientTower.toLowerCase().contains(q) ||
               (p.recipientOwnerId?.toString() ?? '').contains(q) ||
               p.id.toLowerCase().contains(q) ||
               (p.status ?? '').toLowerCase().contains(q) ||
               (p.senderName ?? '').toLowerCase().contains(q);
      });
    }

    return out.toList();
  }

  Future<void> _openFilters(List<String> availableTypes, List<String> statuses) async {
    String? tmpType = _typeFilter;
    String? tmpStatus = _statusFilter;

    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final types = ['Todos', ...availableTypes];
        final states = ['Todos', ...statuses];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filtrar por tipo', style: TextStyle(fontWeight: FontWeight.w600)),
                for (final t in types)
                  RadioListTile<String?>(
                    value: t == 'Todos' ? null : t,
                    groupValue: tmpType,
                    onChanged: (v) {
                      tmpType = v;
                      (ctx as Element).markNeedsBuild();
                    },
                    title: Text(t),
                  ),
                const Divider(),
                const Text('Filtrar por estado', style: TextStyle(fontWeight: FontWeight.w600)),
                for (final s in states)
                  RadioListTile<String?>(
                    value: s == 'Todos' ? null : s,
                    groupValue: tmpStatus,
                    onChanged: (v) {
                      tmpStatus = v;
                      (ctx as Element).markNeedsBuild();
                    },
                    title: Text(s ?? 'Todos'),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted) return;
    setState(() {
      _typeFilter = tmpType;
      _statusFilter = tmpStatus;
    });
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '—';
    final d = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
    // If you use intl, prefer DateFormat('y-MM-dd HH:mm').format(d)
  }

  void _showPackageDetail(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Detalle del paquete'),
          content: FutureBuilder<Packages>(
            future: _service.fetchById(id),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
              }
              if (snap.hasError) return Text('Error: ${snap.error}');
              final p = snap.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${p.id}'),
                  Text('Código: ${p.packageId}'),
                  Text('Tipo: ${p.packageType}'),
                  Text('Estado: ${p.status ?? '—'}'),
                  Text('Descripción: ${p.description ?? '—'}'),
                  Text('Remitente: ${p.senderName ?? '—'}'),
                  Text('Empresa: ${p.senderCompany ?? '—'}'),
                  Text('Tamaño: ${p.size ?? '—'}'),
                  Text('Peso: ${p.weight?.toStringAsFixed(2) ?? '—'} kg'),
                  Text('Notas guardia: ${p.guardNotes ?? '—'}'),
                  Text('Notas entrega: ${p.deliveryNotes ?? '—'}'),
                  Text('Firma receptor: ${p.recipientSignature ?? '—'}'),
                  Text('Propietario ID: ${p.recipientOwnerId ?? '—'}'),
                  Text('Apto: ${p.recipientApartment}'),
                  Text('Torre: ${p.recipientTower}'),
                  Text('Creado: ${_fmtDate(p.createdAt)}'),
                  Text('Actualizado: ${_fmtDate(p.updatedAt)}'),
                  Text('Fotos: ${p.photos.length}'),
                ],
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
          ],
        );
      },
    );
  }

  Future<void> _showCreateDialog() async {
    final formKey = GlobalKey<FormState>();
    final ownerCtrl = TextEditingController();
    final apartmentCtrl = TextEditingController();
    final towerCtrl = TextEditingController();
    final senderNameCtrl = TextEditingController();
    final senderCompanyCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    final guardNotesCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    String packageType = 'package';
    String size = 'medium';
    bool submitting = false;

    Future<void> submit(StateSetter setStateDialog) async {
      final form = formKey.currentState;
      if (form == null || !form.validate()) return;

      final payload = {
        'recipient_owner_id': int.parse(ownerCtrl.text.trim()),
        'recipient_apartment': apartmentCtrl.text.trim(),
        'recipient_tower': towerCtrl.text.trim(),
        'sender_name': senderNameCtrl.text.trim(),
        'sender_company': senderCompanyCtrl.text.trim().isEmpty
            ? null
            : senderCompanyCtrl.text.trim(),
        'description': descriptionCtrl.text.trim().isEmpty
            ? null
            : descriptionCtrl.text.trim(),
        'package_type': packageType,
        'size': size,
        'weight': weightCtrl.text.trim().isEmpty
            ? null
            : double.tryParse(weightCtrl.text.trim()),
        'guard_notes': guardNotesCtrl.text.trim().isEmpty
            ? null
            : guardNotesCtrl.text.trim(),
      };

      setStateDialog(() => submitting = true);
      try {
        await _service.registerPackage(payload);
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paquete registrado correctamente')),
        );
        await _refresh();
      } on DioException catch (e) {
        if (!mounted) return;
        final message = e.response?.data is Map &&
                (e.response!.data as Map)['error'] is String
            ? (e.response!.data as Map)['error'] as String
            : e.message ?? 'Error al registrar el paquete';
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
                'Registrar paquete',
                style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w700),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: ownerCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _fieldDecoration('Propietario (ID)'),
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
                        controller: apartmentCtrl,
                        decoration: _fieldDecoration('Apartamento'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: towerCtrl,
                        decoration: _fieldDecoration('Torre'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: senderNameCtrl,
                        decoration: _fieldDecoration('Remitente'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: senderCompanyCtrl,
                        decoration: _fieldDecoration('Empresa (opcional)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionCtrl,
                        decoration: _fieldDecoration('Descripción (opcional)'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: packageType,
                        decoration: _fieldDecoration('Tipo de paquete'),
                        items: const [
                          DropdownMenuItem(value: 'package', child: Text('Paquete')),
                          DropdownMenuItem(value: 'envelope', child: Text('Sobre')),
                          DropdownMenuItem(value: 'document', child: Text('Documento')),
                          DropdownMenuItem(value: 'other', child: Text('Otro')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setStateDialog(() => packageType = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: size,
                        decoration: _fieldDecoration('Tamaño'),
                        items: const [
                          DropdownMenuItem(value: 'small', child: Text('Pequeño')),
                          DropdownMenuItem(value: 'medium', child: Text('Mediano')),
                          DropdownMenuItem(value: 'large', child: Text('Grande')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setStateDialog(() => size = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _fieldDecoration('Peso (kg)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: guardNotesCtrl,
                        decoration: _fieldDecoration('Notas del guardia (opcional)'),
                        maxLines: 2,
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

  Future<void> _showStatusDialog(Packages package) async {
    final formKey = GlobalKey<FormState>();
    String status = package.status ?? 'pending';
    final deliveryNotesCtrl = TextEditingController(text: package.deliveryNotes ?? '');
    final signatureCtrl = TextEditingController(text: package.recipientSignature ?? '');
    bool submitting = false;

    Future<void> submit(StateSetter setStateDialog) async {
      final form = formKey.currentState;
      if (form == null || !form.validate()) return;

      final payload = {
        'status': status,
        'delivery_notes': deliveryNotesCtrl.text.trim().isEmpty
            ? null
            : deliveryNotesCtrl.text.trim(),
        'recipient_signature': signatureCtrl.text.trim().isEmpty
            ? null
            : signatureCtrl.text.trim(),
      };

      setStateDialog(() => submitting = true);
      try {
        await _service.updateStatus(package.packageId, payload);
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: _fieldDecoration('Estado'),
                      items: const [
                        DropdownMenuItem(value: 'pending', child: Text('Pendiente')),
                        DropdownMenuItem(value: 'notified', child: Text('Notificado')),
                        DropdownMenuItem(value: 'delivered', child: Text('Entregado')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setStateDialog(() => status = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: deliveryNotesCtrl,
                      decoration: _fieldDecoration('Notas de entrega'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: signatureCtrl,
                      decoration: _fieldDecoration('Firma del receptor'),
                    ),
                  ],
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
    final canManage = _canManagePackages;
    return Scaffold(
      backgroundColor: lightBackground,
      body: FutureBuilder<List<Packages>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? const <Packages>[];
          final visible = _applyFilters(items);

          // Unique package types for filter sheet
          final availableTypes = items
              .map((p) => p.packageType)
              .where((t) => t.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          final availableStatuses = items
              .map((p) => p.status ?? '')
              .where((t) => t.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Paquetes',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    if (canManage)
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
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Buscar...',
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
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _openFilters(availableTypes, availableStatuses),
                      icon: const Icon(Icons.filter_list, color: textColor),
                      label: Text(
                        (_typeFilter == null && _statusFilter == null)
                            ? 'Filtros'
                            : 'Filtros activos',
                        style: const TextStyle(color: textColor),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(0, 40),
                      ),
                    ),
                  ],
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
                        DataColumn(label: Text('Código')),
                        DataColumn(label: Text('Tipo')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Apto')),
                        DataColumn(label: Text('Torre')),
                        DataColumn(label: Text('Owner ID')),
                        DataColumn(label: Text('Creado')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: visible.map((p) {
                        return DataRow(cells: [
                          DataCell(Text(p.packageId)),
                          DataCell(Text(p.packageType)),
                          DataCell(Text(p.status ?? '—')),
                          DataCell(Text(p.recipientApartment)),
                          DataCell(Text(p.recipientTower)),
                          DataCell(Text(p.recipientOwnerId?.toString() ?? '—')),
                          DataCell(Text(_fmtDate(p.createdAt))),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_red_eye_outlined),
                                tooltip: 'Ver',
                                onPressed: () => _showPackageDetail(context, p.id),
                              ),
                              if (canManage)
                                IconButton(
                                  icon: const Icon(Icons.edit_note_outlined),
                                  tooltip: 'Actualizar estado',
                                  onPressed: () => _showStatusDialog(p),
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
                            ? 'No tienes paquetes registrados.'
                            : 'No hay paquetes disponibles.',
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
