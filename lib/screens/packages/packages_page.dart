import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/models/packages/packages_model.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/services/packages_service.dart';
import 'package:valhalla_android/services/owner_service.dart';
import 'package:valhalla_android/utils/colors.dart';
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
  List<Map<String, dynamic>> owners = [];
  bool loadingOwners = false;
  String? selectedOwnerId;
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
    _loadOwners();
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

    // Filtro por tipo de paquete
    if (_typeFilter != null && _typeFilter!.isNotEmpty) {
      final f = _typeFilter!.toLowerCase();
      out = out.where((p) => p.packageType.toLowerCase() == f);
    }

    // Filtro por estado
    if (_statusFilter != null && _statusFilter!.isNotEmpty) {
      final f = _statusFilter!.toLowerCase();
      out = out.where((p) => p.status.toLowerCase() == f);
    }

    // Filtro por búsqueda general
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      out = out.where((p) {
        // Búsqueda en campos directos del paquete
        bool matches =
            p.packageId.toLowerCase().contains(q) ||
            p.packageType.toLowerCase().contains(q) ||
            p.recipientApartment.toLowerCase().contains(q) ||
            p.recipientTower.toLowerCase().contains(q) ||
            p.recipientOwnerId.toString().contains(q) ||
            p.id.toLowerCase().contains(q) ||
            (p.description?.toLowerCase() ?? '').contains(q) ||
            (p.senderName?.toLowerCase() ?? '').contains(q) ||
            (p.carrier?.toLowerCase() ?? '').contains(q);

        // Búsqueda en owner_info (datos del propietario)
        if (!matches && p.ownerInfo != null) {
          matches =
              (p.ownerInfo?['name']?.toString().toLowerCase() ?? '').contains(
                q,
              ) ||
              (p.ownerInfo?['email']?.toString().toLowerCase() ?? '').contains(
                q,
              ) ||
              (p.ownerInfo?['apartment']?.toString().toLowerCase() ?? '')
                  .contains(q) ||
              (p.ownerInfo?['tower']?.toString().toLowerCase() ?? '').contains(
                q,
              );
        }

        // Búsqueda en guard_info (datos del guardia)
        if (!matches && p.guardInfo != null) {
          matches =
              (p.guardInfo?['name']?.toString().toLowerCase() ?? '').contains(
                q,
              ) ||
              (p.guardInfo?['email']?.toString().toLowerCase() ?? '').contains(
                q,
              );
        }

        // Búsqueda por ID del guardia
        if (!matches) {
          matches = (p.guardId?.toString() ?? '').contains(q);
        }

        // Búsqueda por urgente
        if (!matches && (q == 'urgente' || q == 'si' || q == 'true')) {
          matches = p.urgent;
        }
        if (!matches && (q == 'normal' || q == 'no' || q == 'false')) {
          matches = !p.urgent;
        }

        return matches;
      });
    }

    // Ordenar por fecha de recepción (más reciente primero)
    out = out.toList()
      ..sort((a, b) {
        final aDate = a.receivedAt ?? DateTime(0);
        final bDate = b.receivedAt ?? DateTime(0);
        return bDate.compareTo(aDate); // Descendente
      });

    return out.toList();
  }

  Future<void> _openFilters(
    List<String> availableTypes,
    List<String> statuses,
  ) async {
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
                const Text(
                  'Filtrar por tipo',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
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
                const Text(
                  'Filtrar por estado',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                for (final s in states)
                  RadioListTile<String?>(
                    value: s == 'Todos' ? null : s,
                    groupValue: tmpStatus,
                    onChanged: (v) {
                      tmpStatus = v;
                      (ctx as Element).markNeedsBuild();
                    },
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

  void _deletePackage(String packageId) async {
    try {
      // Mostrar un diálogo de confirmación
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de eliminar este paquete?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Mostrar loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // Llamar a tu método delete
        await _service.delete(packageId);

        // Cerrar loading
        Navigator.pop(context);

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paquete eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Si estás en una lista, recargar los datos
        // _loadPackages(); // Descomenta si necesitas recargar
      }
    } catch (e) {
      // Cerrar loading si está abierto
      Navigator.pop(context);

      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) return Text('Error: ${snap.error}');
              final p = snap.data!;
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow('Código', p.packageId),
                    _detailRow('Tipo', (p.packageType)),
                    _detailRow('Propietario', p.ownerName ?? 'N/A'),
                    _detailRow('Email', p.ownerEmail ?? 'N/A'),
                    _detailRow(
                      'Apto/Torre',
                      '${p.recipientApartment}-${p.recipientTower}',
                    ),
                    _detailRow('Estado', _capitalize(p.status)),
                    _detailRow('Recibido por', p.guardName ?? 'N/A'),
                    _detailRow('Fecha recepción', _fmtDate(p.receivedAt)),

                    // Solo mostrar si el paquete fue entregado
                    if (p.deliveredToOwner != null &&
                        p.deliveredToOwner!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const Text(
                        'Entrega:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      _detailRow(
                        'Entregado por',
                        p.guardInfo?['name']?.toString() ?? 'N/A',
                      ),
                      _detailRow(
                        'Fecha entrega',
                        _fmtDate(p.deliveredToOwner?['delivered_at']),
                      ),
                      if (p.deliveredToOwner?['recipient_signature'] != null)
                        _detailRow('Firma', 'Presente'),
                    ],
                  ],
                ),
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

  // Método auxiliar para formatear filas
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Método auxiliar para capitalizar
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _showCreateDialog() async {
    final formKey = GlobalKey<FormState>();
    final senderCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    final carrierCtrl = TextEditingController();
    String packageType = 'package';
    bool urgent = false;
    bool submitting = false;

    // Variable para el ID del owner (inicialmente vacío)
    String? selectedOwnerId;

    Future<void> submit(StateSetter setStateDialog) async {
      final form = formKey.currentState;
      if (form == null || !form.validate()) return;

      if (selectedOwnerId == null || selectedOwnerId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe seleccionar un propietario')),
        );
        return;
      }

      final payload = {
        'recipient_owner_id': int.parse(selectedOwnerId!),
        'package_type': packageType,
        'sender_name': senderCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
        'carrier': carrierCtrl.text.trim(),
        'urgent': urgent,
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
        final message =
            e.response?.data is Map &&
                (e.response!.data as Map)['error'] is String
            ? (e.response!.data as Map)['error'] as String
            : e.message ?? 'Error al registrar el paquete';
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
                'Registrar paquete',
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
                      // En lugar del TextFormField, usa:
                      DropdownButtonFormField<String>(
                        value: selectedOwnerId,
                        decoration: _fieldDecoration('Propietario'),
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

                          // Estado cargado - mostrar owners (solo name, sin apartment/tower)
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
                        onChanged: (value) {
                          setStateDialog(() => selectedOwnerId = value);
                        },
                      ),
                      const SizedBox(height: 12),

                      // ✅ 2. Tipo de paquete FIJO
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              color: secondaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Tipo de paquete:',
                              style: TextStyle(color: Color(0xFF666666)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: secondaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Paquete',
                                style: TextStyle(
                                  color: secondaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ✅ 3. Nombre del remitente (obligatorio)
                      TextFormField(
                        controller: senderCtrl,
                        decoration: _fieldDecoration('Nombre del remitente'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // ✅ 4. Descripción (obligatoria)
                      TextFormField(
                        controller: descriptionCtrl,
                        decoration: _fieldDecoration('Descripción del paquete'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // ✅ 5. Empresa de mensajería (opcional)
                      TextFormField(
                        controller: carrierCtrl,
                        decoration: _fieldDecoration(
                          'Empresa de mensajería (opcional)',
                        ),
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
                  onPressed: submitting ? null : () => Navigator.pop(ctx),
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Registrar'),
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
          final availableTypes =
              items
                  .map((p) => p.packageType)
                  .where((t) => t.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();

          final availableStatuses =
              items
                  .map((p) => p.status)
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
                    const Text(
                      'Paquetes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                    if (canManage)
                      ElevatedButton.icon(
                        onPressed: _showCreateDialog,
                        icon: const Icon(Icons.add),
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
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
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
                                    onPressed: () => _searchCtrl.clear(),
                                  ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
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
                          borderRadius: BorderRadius.circular(20),
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
                        DataColumn(label: Text('Propietario')),
                        DataColumn(label: Text('Apto/Torre')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Guardia')),
                        DataColumn(label: Text('Fecha')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: visible.map((p) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Tooltip(
                                message: p.packageId,
                                child: Text(
                                  p.packageId.length > 10
                                      ? '${p.packageId.substring(0, 10)}...'
                                      : p.packageId,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Chip(
                                label: Text(
                                  (p.packageType),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    p.ownerName ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (p.ownerEmail != null)
                                    Text(
                                      p.ownerEmail!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(
                                '${p.recipientApartment}-${p.recipientTower}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DataCell(
                              Chip(
                                label: Text(
                                  p.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: p.status == 'entregado'
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                                backgroundColor: p.status == 'entregado'
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            DataCell(
                              Tooltip(
                                message: p.guardName ?? 'N/A',
                                child: SizedBox(
                                  width: 80,
                                  child: Text(
                                    p.guardName ?? '—',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                _fmtDate(p.receivedAt),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_red_eye_outlined,
                                      size: 20,
                                    ),
                                    tooltip: 'Ver detalles',
                                    onPressed: () =>
                                        _showPackageDetail(context, p.id),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Eliminar',
                                    onPressed: () => _deletePackage(p.id),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
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
