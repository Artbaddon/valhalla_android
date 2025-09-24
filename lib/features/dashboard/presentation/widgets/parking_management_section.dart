import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/parking_spot.dart';
import '../viewmodels/admin_viewmodel.dart';

class ParkingManagementSection extends StatefulWidget {
  const ParkingManagementSection({super.key});

  @override
  State<ParkingManagementSection> createState() => _ParkingManagementSectionState();
}

class _ParkingManagementSectionState extends State<ParkingManagementSection> {
  String _selectedFilter = 'todos';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadParkingSpots();
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
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestión de Estacionamiento',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Administra todos los espacios de estacionamiento',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary.withOpacity(0.8),
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
              hintText: 'Buscar por número o propietario...',
              prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.textMuted),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            onChanged: (value) {
              viewModel.setParkingFilter(
                searchTerm: value.isEmpty ? null : value,
                status: _selectedFilter == 'todos' ? null : _selectedFilter,
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
                _buildFilterChip('disponible', 'Disponibles', viewModel),
                const SizedBox(width: 8),
                _buildFilterChip('ocupado', 'Ocupados', viewModel),
                const SizedBox(width: 8),
                _buildFilterChip('reservado', 'Reservados', viewModel),
                const SizedBox(width: 8),
                _buildFilterChip('mantenimiento', 'Mantenimiento', viewModel),
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
      selectedColor: AppColors.primary,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        viewModel.setParkingFilter(
          searchTerm: _searchController.text.isEmpty ? null : _searchController.text,
          status: value == 'todos' ? null : value,
        );
      },
    );
  }

  Widget _buildContent(AdminViewModel viewModel) {
    if (viewModel.isParkingLoading) {
      return const LoadingWidget(message: 'Cargando espacios...');
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
                viewModel.loadParkingSpots();
              },
            ),
          ],
        ),
      );
    }

    final filteredSpots = viewModel.filteredParkingSpots;

    if (filteredSpots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_parking_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron espacios',
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta ajustar los filtros de búsqueda',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredSpots.length,
      itemBuilder: (context, index) {
        final spot = filteredSpots[index];
        return _buildParkingSpotCard(spot, viewModel);
      },
    );
  }

  Widget _buildParkingSpotCard(ParkingSpot spot, AdminViewModel viewModel) {
    Color statusColor;
    IconData statusIcon;
    
    switch (spot.status.toLowerCase()) {
      case 'disponible':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'ocupado':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
      case 'reservado':
        statusColor = AppColors.warning;
        statusIcon = Icons.schedule;
        break;
      case 'mantenimiento':
        statusColor = AppColors.info;
        statusIcon = Icons.build;
        break;
      default:
        statusColor = AppColors.textMuted;
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
        onTap: () => _showParkingSpotDetails(spot, viewModel),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Espacio ${spot.number}',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tipo: ${spot.type}',
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
                      spot.status.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (spot.ownerName != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Propietario: ${spot.ownerName}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
              if (spot.vehiclePlate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Vehículo: ${spot.vehiclePlate}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showParkingSpotDetails(ParkingSpot spot, AdminViewModel viewModel) {
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Espacio ${spot.number}',
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailItem('Tipo', spot.type),
                  _buildDetailItem('Estado', spot.status),
                  if (spot.ownerName != null)
                    _buildDetailItem('Propietario', spot.ownerName!),
                  if (spot.ownerEmail != null)
                    _buildDetailItem('Email', spot.ownerEmail!),
                  if (spot.vehiclePlate != null)
                    _buildDetailItem('Placa', spot.vehiclePlate!),
                  if (spot.vehicleModel != null)
                    _buildDetailItem('Modelo', spot.vehicleModel!),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Editar',
                          onPressed: () {
                            Navigator.pop(context);
                            _showEditDialog(spot, viewModel);
                          },
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Liberar',
                          onPressed: spot.status.toLowerCase() != 'disponible' 
                              ? () async {
                                  Navigator.pop(context);
                                  await viewModel.updateParkingSpotStatus(
                                    spot.id, 
                                    'disponible',
                                  );
                                } 
                              : null,
                          backgroundColor: AppColors.success,
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

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  void _showEditDialog(ParkingSpot spot, AdminViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Espacio ${spot.number}'),
        content: const Text('Función de edición próximamente disponible'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}