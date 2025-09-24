import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../viewmodels/payments_viewmodel.dart';
import '../widgets/payment_stats_cards.dart';
import '../widgets/payments_list.dart';
import '../widgets/payment_methods_section.dart';
import '../widgets/add_payment_method_dialog.dart';
import '../widgets/create_payment_dialog.dart';

class PaymentsDashboard extends StatefulWidget {
  const PaymentsDashboard({super.key});

  @override
  State<PaymentsDashboard> createState() => _PaymentsDashboardState();
}

class _PaymentsDashboardState extends State<PaymentsDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paymentsViewModel = context.read<PaymentsViewModel>();
      
      // Load initial data
      paymentsViewModel.loadPaymentStats();
      paymentsViewModel.loadPayments();
      paymentsViewModel.loadPaymentMethods();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Pagos',
          style: AppTextStyles.headlineMedium,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textPrimary.withOpacity(0.7),
          indicatorColor: AppColors.textPrimary,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard_outlined),
              text: 'Resumen',
            ),
            Tab(
              icon: Icon(Icons.payment_outlined),
              text: 'Historial',
            ),
            Tab(
              icon: Icon(Icons.credit_card_outlined),
              text: 'Métodos',
            ),
          ],
        ),
      ),
      body: Consumer<PaymentsViewModel>(
        builder: (context, viewModel, child) {
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
                      viewModel.loadPaymentStats();
                      viewModel.loadPayments();
                      viewModel.loadPaymentMethods();
                    },
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildStatsTab(viewModel),
              _buildPaymentsTab(viewModel),
              _buildPaymentMethodsTab(viewModel),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<PaymentsViewModel>(
        builder: (context, viewModel, child) {
          return FloatingActionButton.extended(
            onPressed: () => _showCreatePaymentDialog(context),
            backgroundColor: AppColors.primary,
            icon: Icon(
              Icons.add,
              color: AppColors.textPrimary,
            ),
            label: Text(
              'Nuevo Pago',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsTab(PaymentsViewModel viewModel) {
    if (viewModel.isLoading) {
      return const LoadingWidget(message: 'Cargando estadísticas...');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen Financiero',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Estado de tus pagos y transacciones',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          if (viewModel.paymentStats != null) 
            PaymentStatsCards(stats: viewModel.paymentStats!)
          else 
            Container(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No hay estadísticas disponibles',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 32),
          Text(
            'Acciones Rápidas',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildQuickActionCard(
          title: 'Nuevo Pago',
          icon: Icons.payment,
          color: AppColors.primary,
          onTap: () => _showCreatePaymentDialog(context),
        ),
        _buildQuickActionCard(
          title: 'Métodos de Pago',
          icon: Icons.credit_card,
          color: AppColors.secondary,
          onTap: () => _tabController.animateTo(2),
        ),
        _buildQuickActionCard(
          title: 'Historial',
          icon: Icons.history,
          color: AppColors.info,
          onTap: () => _tabController.animateTo(1),
        ),
        _buildQuickActionCard(
          title: 'Pendientes',
          icon: Icons.schedule,
          color: AppColors.warning,
          onTap: () {
            _tabController.animateTo(1);
            context.read<PaymentsViewModel>().setPaymentFilters(status: 'pending');
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentsTab(PaymentsViewModel viewModel) {
    return PaymentsList(
      payments: viewModel.filteredPayments,
      isLoading: viewModel.isLoading,
      onRefresh: () {
        viewModel.loadPayments();
      },
      onPaymentTap: (payment) {
        // TODO: Navigate to payment details
      },
    );
  }

  Widget _buildPaymentMethodsTab(PaymentsViewModel viewModel) {
    return PaymentMethodsSection(
      paymentMethods: viewModel.paymentMethods,
      isLoading: viewModel.isLoading,
      onAddMethod: () => _showAddPaymentMethodDialog(context, viewModel),
      onEditMethod: (method) => _showEditPaymentMethodDialog(context, viewModel, method),
      onDeleteMethod: (method) => _deletePaymentMethod(context, viewModel, method),
      onSetDefault: (method) => _setDefaultPaymentMethod(context, viewModel, method),
    );
  }

  void _showCreatePaymentDialog(BuildContext context) {
    final viewModel = context.read<PaymentsViewModel>();
    showDialog(
      context: context,
      builder: (context) => CreatePaymentDialog(
        paymentMethods: viewModel.paymentMethods,
        onCreate: (payment) {
          viewModel.createPayment(
            description: payment.description,
            amount: payment.amount,
            category: payment.category,
            paymentMethodId: 1, // This should come from selected payment method
          );
        },
      ),
    );
  }

  void _showAddPaymentMethodDialog(BuildContext context, PaymentsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AddPaymentMethodDialog(
        onSave: (method) {
          viewModel.addPaymentMethod(
            type: method.type,
            name: method.name,
            cardNumber: method.cardNumber,
            expiryDate: method.expiryDate,
            holderName: method.holderName,
            bankName: method.bankName,
            isDefault: method.isDefault,
          );
        },
      ),
    );
  }

  void _showEditPaymentMethodDialog(BuildContext context, PaymentsViewModel viewModel, paymentMethod) {
    showDialog(
      context: context,
      builder: (context) => AddPaymentMethodDialog(
        existingMethod: paymentMethod,
        onSave: (method) {
          viewModel.addPaymentMethod(
            type: method.type,
            name: method.name,
            cardNumber: method.cardNumber,
            expiryDate: method.expiryDate,
            holderName: method.holderName,
            bankName: method.bankName,
            isDefault: method.isDefault,
          );
        },
      ),
    );
  }

  void _deletePaymentMethod(BuildContext context, PaymentsViewModel viewModel, paymentMethod) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Método'),
        content: Text('¿Estás seguro de que quieres eliminar "${paymentMethod.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.deletePaymentMethod(paymentMethod.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _setDefaultPaymentMethod(BuildContext context, PaymentsViewModel viewModel, paymentMethod) {
    viewModel.setDefaultPaymentMethod(paymentMethod.id);
  }
}