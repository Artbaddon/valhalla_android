import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/facility.dart';
import '../viewmodels/reservations_viewmodel.dart';
import '../widgets/reservation_card.dart';
import '../widgets/facility_selection_card.dart';
import '../widgets/new_reservation_dialog.dart';

class ReservationsDashboardPage extends StatefulWidget {
  const ReservationsDashboardPage({super.key});

  @override
  State<ReservationsDashboardPage> createState() => _ReservationsDashboardPageState();
}

class _ReservationsDashboardPageState extends State<ReservationsDashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ReservationsViewModel>();
      viewModel.refresh();
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
      appBar: AppBar(
        title: const Text('Reservations'),
        automaticallyImplyLeading: false,
        actions: [
          Consumer<ReservationsViewModel>(
            builder: (context, viewModel, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: viewModel.isLoading ? null : viewModel.refresh,
              );
            },
          ),
        ],
      ),
      body: Consumer<ReservationsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.error != null) {
            return _buildErrorView(viewModel);
          }

          return Column(
            children: [
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCalendarTab(viewModel),
                    _buildMyReservationsTab(viewModel),
                    _buildFacilitiesTab(viewModel),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewReservationDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.calendar_today), text: 'Calendar'),
          Tab(icon: Icon(Icons.list), text: 'My Reservations'),
          Tab(icon: Icon(Icons.location_city), text: 'Facilities'),
        ],
      ),
    );
  }

  Widget _buildCalendarTab(ReservationsViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: TableCalendar<Reservation>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: viewModel.selectedDate,
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) => viewModel.getReservationsByDate(day),
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                holidayTextStyle: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                viewModel.setSelectedDate(selectedDay);
              },
              onPageChanged: (focusedDay) {
                viewModel.setSelectedDate(focusedDay);
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildDayReservations(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildDayReservations(ReservationsViewModel viewModel) {
    final dayReservations = viewModel.getReservationsByDate(viewModel.selectedDate);
    
    if (dayReservations.isEmpty) {
      return Card(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No reservations for this date',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: dayReservations.length,
        itemBuilder: (context, index) {
          return ReservationCard(
            reservation: dayReservations[index],
            onCancel: viewModel.cancelReservation,
          );
        },
      ),
    );
  }

  Widget _buildMyReservationsTab(ReservationsViewModel viewModel) {
    if (viewModel.isLoading && viewModel.reservations.isEmpty) {
      return const LoadingWidget();
    }

    if (viewModel.reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No reservations yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first reservation',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
              Tab(text: 'All'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildReservationList(viewModel.upcomingReservations, viewModel),
                _buildReservationList(viewModel.pastReservations, viewModel),
                _buildReservationList(viewModel.reservations, viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationList(List<Reservation> reservations, ReservationsViewModel viewModel) {
    if (reservations.isEmpty) {
      return const Center(
        child: Text('No reservations found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ReservationCard(
            reservation: reservations[index],
            onCancel: viewModel.cancelReservation,
          ),
        );
      },
    );
  }

  Widget _buildFacilitiesTab(ReservationsViewModel viewModel) {
    if (viewModel.isLoading && viewModel.facilities.isEmpty) {
      return const LoadingWidget();
    }

    if (viewModel.facilities.isEmpty) {
      return const Center(
        child: Text('No facilities available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: viewModel.availableFacilities.length,
      itemBuilder: (context, index) {
        final facility = viewModel.availableFacilities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: FacilitySelectionCard(
            facility: facility,
            isSelected: viewModel.selectedFacility?.id == facility.id,
            onTap: () => viewModel.setSelectedFacility(facility),
          ),
        );
      },
    );
  }

  Widget _buildErrorView(ReservationsViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                viewModel.clearError();
                viewModel.refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewReservationDialog() {
    showDialog(
      context: context,
      builder: (context) => const NewReservationDialog(),
    );
  }
}