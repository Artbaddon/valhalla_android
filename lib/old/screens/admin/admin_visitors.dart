import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:valhalla_android/models/visitor/visitor_model.dart';
import 'package:valhalla_android/services/visitor_service.dart';
import 'package:valhalla_android/utils/colors.dart';

class AdminVisitorsPage extends StatelessWidget {
  const AdminVisitorsPage({super.key});

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '—';
    final d = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  void _showVisitorDetail(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Detalle de visitante'),
        content: FutureBuilder<Visitor>(
          future: VisitorService().fetchById(id),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snap.hasError) return Text('Error: ${snap.error}');
            final v = snap.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${v.id}'),
                Text('Nombre: ${v.name}'),
                Text('Documento: ${v.documentNumber}'),
                Text('Anfitrión: ${v.hostName} (#${v.hostId ?? '—'})'),
                Text('Entrada: ${_fmtDate(v.enterDate)}'),
                Text('Salida: ${_fmtDate(v.exitDate)}'),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final future = VisitorService().fetchAll();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Visitantes',
          style: TextStyle(color: AppColors.purple),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.purple),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: FutureBuilder<List<Visitor>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final items = snapshot.data ?? const <Visitor>[];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Documento')),
                    DataColumn(label: Text('Anfitrión')),
                    DataColumn(label: Text('Entrada')),
                    DataColumn(label: Text('Salida')),
                    DataColumn(label: Icon(CupertinoIcons.eye)),
                  ],
                  rows: items.map((v) {
                    return DataRow(
                      cells: [
                        DataCell(Text(v.name)),
                        DataCell(Text(v.documentNumber)),
                        DataCell(Text(v.hostName)),
                        DataCell(Text(_fmtDate(v.enterDate))),
                        DataCell(Text(_fmtDate(v.exitDate))),
                        DataCell(
                          IconButton(
                            icon: const Icon(CupertinoIcons.eye),
                            onPressed: () => _showVisitorDetail(context, v.id),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
