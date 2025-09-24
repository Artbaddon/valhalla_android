import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/visitor.dart';
import '../viewmodels/admin_viewmodel.dart';

class VisitorManagementSection extends StatefulWidget {
  const VisitorManagementSection({super.key});

  @override
  State<VisitorManagementSection> createState() => _VisitorManagementSectionState();
}

class _VisitorManagementSectionState extends State<VisitorManagementSection> {
  String _selectedFilter = 'todos';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadVisitors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            _buildHeader(),
            _buildFilters(viewModel),
            Expanded(
              child: _buildContent(viewModel),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestión de Visitantes',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Administra el registro de visitantes',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          FloatingActionButton(
            mini: true,
            backgroundColor: AppColors.primary,
            onPressed: () => _showCreateVisitorDialog(),
            child: Icon(
              Icons.add,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(AdminViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, documento o anfitrión...',
              prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.textMuted),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.secondary),
              ),
            ),
            onChanged: (value) {
              viewModel.setVisitorFilters(
                searchQuery: value.isEmpty ? null : value,
                statusFilter: _selectedFilter == 'todos' ? null : _selectedFilter,
              );
            },
          ),
          const SizedBox(height: 16),
          // Status filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('todos', 'Todos', viewModel),
                const SizedBox(width: 8),
                _buildFilterChip('activo', 'Activos', viewModel),
                const SizedBox(width: 8),
                _buildFilterChip('finalizado', 'Finalizados', viewModel),
                const SizedBox(width: 8),
                _buildFilterChip('pendiente', 'Pendientes', viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, AdminViewModel viewModel) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: isSelected ? AppColors.textPrimary : AppColors.textDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.secondary,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        viewModel.setVisitorFilters(
          searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
          statusFilter: value == 'todos' ? null : value,
        );
      },
    );
  }

  Widget _buildContent(AdminViewModel viewModel) {
    if (viewModel.isVisitorsLoading) {
      return const LoadingWidget(message: 'Cargando visitantes...');
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${viewModel.errorMessage}',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Reintentar',
              onPressed: () {
                viewModel.clearError();
                viewModel.loadVisitors();
              },
            ),
          ],
        ),
      );
    }

    final filteredVisitors = viewModel.filteredVisitors;

    if (filteredVisitors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron visitantes',
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta ajustar los filtros de búsqueda',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Registrar Visitante',
              onPressed: () => _showCreateVisitorDialog(),
              backgroundColor: AppColors.secondary,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredVisitors.length,
      itemBuilder: (context, index) {
        final visitor = filteredVisitors[index];
        return _buildVisitorCard(visitor, viewModel);
      },
    );
  }

  Widget _buildVisitorCard(Visitor visitor, AdminViewModel viewModel) {
    Color statusColor;
    IconData statusIcon;
    
    switch (visitor.status.toLowerCase()) {
      case 'activo':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'finalizado':
        statusColor = AppColors.textMuted;
        statusIcon = Icons.history;
        break;
      case 'pendiente':
        statusColor = AppColors.warning;
        statusIcon = Icons.schedule;
        break;
      default:
        statusColor = AppColors.info;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showVisitorDetails(visitor, viewModel),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visitor.name,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Doc: ${visitor.documentNumber}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      visitor.status.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Anfitrión: ${visitor.hostName}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Entrada: ${visitor.enterDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                    style: AppTextStyles.bodySmall,
                  ),
                  if (visitor.exitDate != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.exit_to_app,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Salida: ${visitor.exitDate!.toLocal().toString().split(' ')[0]}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVisitorDetails(Visitor visitor, AdminViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visitor.name,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailItem('Documento', visitor.documentNumber),
                    _buildDetailItem('Estado', visitor.status),
                    _buildDetailItem('Anfitrión', visitor.hostName),
                    if (visitor.hostId != null)
                      _buildDetailItem('ID Anfitrión', visitor.hostId.toString()),
                    if (visitor.enterDate != null)
                      _buildDetailItem('Fecha Entrada', visitor.enterDate!.toLocal().toString()),
                    if (visitor.exitDate != null)
                      _buildDetailItem('Fecha Salida', visitor.exitDate!.toLocal().toString()),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        if (visitor.status.toLowerCase() == 'activo') ...[
                          Expanded(
                            child: CustomButton(
                              text: 'Marcar Salida',
                              onPressed: () async {
                                Navigator.pop(context);
                                await viewModel.updateVisitorStatus(
                                  visitor.id, 
                                  'finalizado',
                                );
                              },
                              backgroundColor: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: CustomButton(
                            text: 'Cerrar',
                            onPressed: () => Navigator.pop(context),
                            backgroundColor: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateVisitorDialog() {
    final nameController = TextEditingController();
    final documentController = TextEditingController();
    final hostController = TextEditingController();
    final vehicleController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Visitante'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: documentController,
                decoration: const InputDecoration(
                  labelText: 'Número de documento',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hostController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del anfitrión',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: vehicleController,
                decoration: const InputDecoration(
                  labelText: 'Placa del vehículo (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          Consumer<AdminViewModel>(
            builder: (context, viewModel, child) {
              return ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      documentController.text.isEmpty ||
                      hostController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, completa los campos requeridos'),
                      ),
                    );
                    return;
                  }

                  final visitor = await viewModel.createVisitor(
                    name: nameController.text,
                    documentNumber: documentController.text,
                    hostName: hostController.text,
                    vehiclePlate: vehicleController.text.isEmpty ? null : vehicleController.text,
                    phoneNumber: phoneController.text.isEmpty ? null : phoneController.text,
                  );

                  if (visitor != null) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Visitante registrado exitosamente'),
                      ),
                    );
                  }
                },
                child: const Text('Registrar'),
              );
            },
          ),
        ],
      ),
    );
  }
}