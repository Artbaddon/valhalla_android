import 'package:flutter/material.dart';
import 'package:valhalla_android/models/packages/packages_model.dart';
import 'package:valhalla_android/services/packages_service.dart';
import 'dart:async';

const Color secondaryColor = Color.fromRGBO(73, 76, 162, 1);
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

  // search/filter
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _query = '';
  String? _typeFilter; // null = all

  @override
  void initState() {
    super.initState();
    _future = _service.fetchAll();
    _searchCtrl.addListener(() {
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

  List<Packages> _applyFilters(List<Packages> items) {
    Iterable<Packages> out = items;

    if (_typeFilter != null && _typeFilter!.isNotEmpty) {
      final f = _typeFilter!.toLowerCase();
      out = out.where((p) => (p.packageType).toLowerCase() == f);
    }

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      out = out.where((p) {
        return p.packageId.toLowerCase().contains(q) ||
               p.packageType.toLowerCase().contains(q) ||
               p.recipientApartment.toLowerCase().contains(q) ||
               p.recipientTower.toLowerCase().contains(q) ||
               (p.recipientOwnerId?.toString() ?? '').contains(q) ||
               p.id.toLowerCase().contains(q);
      });
    }

    return out.toList();
  }

  Future<void> _openFilters(List<String> availableTypes) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (ctx) {
        final types = ['Todos', ...availableTypes];
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(title: Text('Filtrar por tipo')),
              for (final t in types)
                RadioListTile<String?>(
                  value: t == 'Todos' ? null : t,
                  groupValue: _typeFilter,
                  onChanged: (v) => Navigator.pop(ctx, v),
                  title: Text(t),
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

  @override
  Widget build(BuildContext context) {
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Paquetes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _openFilters(availableTypes),
                      icon: const Icon(Icons.filter_list, color: textColor),
                      label: Text(
                        _typeFilter == null ? 'Filtros' : _typeFilter!,
                        style: const TextStyle(color: textColor),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(0, 40),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Table
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Código')),
                        DataColumn(label: Text('Tipo')),
                        DataColumn(label: Text('Apto')),
                        DataColumn(label: Text('Torre')),
                        DataColumn(label: Text('Owner ID')),
                        DataColumn(label: Text('Creado')),
                        DataColumn(label: Text('Fotos')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: visible.map((p) {
                        return DataRow(cells: [
                          DataCell(Text(p.packageId)),
                          DataCell(Text(p.packageType)),
                          DataCell(Text(p.recipientApartment)),
                          DataCell(Text(p.recipientTower)),
                          DataCell(Text(p.recipientOwnerId?.toString() ?? '—')),
                          DataCell(Text(_fmtDate(p.createdAt))),
                          DataCell(Text(p.photos.length.toString())),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye_outlined),
                              onPressed: () => _showPackageDetail(context, p.id),
                              tooltip: 'Ver',
                            ),
                          ),
                        ]);
                      }).toList(),
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
