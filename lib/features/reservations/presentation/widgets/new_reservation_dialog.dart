import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/facility.dart';
import '../viewmodels/reservations_viewmodel.dart';

class NewReservationDialog extends StatefulWidget {
  const NewReservationDialog({super.key});

  @override
  State<NewReservationDialog> createState() => _NewReservationDialogState();
}

class _NewReservationDialogState extends State<NewReservationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  Facility? _selectedFacility;
  
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('New Reservation'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              Consumer<ReservationsViewModel>(
                builder: (context, viewModel, child) {
                  return TextButton(
                    onPressed: _isLoading ? null : _submitReservation,
                    child: _isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('BOOK'),
                  );
                },
              ),
            ],
          ),
          body: Consumer<ReservationsViewModel>(
            builder: (context, viewModel, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (viewModel.error != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            viewModel.error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                      
                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'What is this reservation for?',
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Facility Selection
                      _buildFacilitySelection(viewModel),
                      const SizedBox(height: 16),
                      
                      // Date Selection
                      _buildDateSelection(),
                      const SizedBox(height: 16),
                      
                      // Time Selection
                      _buildTimeSelection(),
                      const SizedBox(height: 16),
                      
                      // Duration Display
                      if (_startTime != null && _endTime != null) ...[
                        _buildDurationDisplay(),
                        const SizedBox(height: 16),
                      ],
                      
                      // Notes Field
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          hintText: 'Additional information...',
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      
                      // Summary Card
                      if (_canShowSummary()) _buildSummaryCard(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFacilitySelection(ReservationsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Facility',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (viewModel.facilities.isEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('No facilities available. Please try again later.'),
                  ),
                  TextButton(
                    onPressed: viewModel.loadFacilities,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.availableFacilities.length,
              itemBuilder: (context, index) {
                final facility = viewModel.availableFacilities[index];
                final isSelected = _selectedFacility?.id == facility.id;
                
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 8),
                  child: Card(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    child: InkWell(
                      onTap: () => setState(() {
                        _selectedFacility = isSelected ? null : facility;
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    facility.name,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.onPrimaryContainer
                                          : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 16,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              facility.type,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Capacity: ${facility.capacity}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (facility.hourlyRate != null)
                              Text(
                                '\$${facility.hourlyRate!.toStringAsFixed(2)}/hr',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateSelection() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('Date'),
        subtitle: _selectedDate != null
            ? Text(DateFormat('EEEE, MMM d, y').format(_selectedDate!))
            : const Text('Select a date'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _selectDate,
      ),
    );
  }

  Widget _buildTimeSelection() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Start Time'),
              subtitle: _startTime != null
                  ? Text(_startTime!.format(context))
                  : const Text('Select start time'),
              onTap: () => _selectTime(true),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('End Time'),
              subtitle: _endTime != null
                  ? Text(_endTime!.format(context))
                  : const Text('Select end time'),
              onTap: () => _selectTime(false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationDisplay() {
    if (_startTime == null || _endTime == null) return const SizedBox.shrink();

    final startDateTime = DateTime(2023, 1, 1, _startTime!.hour, _startTime!.minute);
    final endDateTime = DateTime(2023, 1, 1, _endTime!.hour, _endTime!.minute);
    final duration = endDateTime.difference(startDateTime);

    if (duration.isNegative) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'End time must be after start time',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    String durationText = '';
    if (hours > 0) durationText += '${hours}h ';
    if (minutes > 0) durationText += '${minutes}m';
    durationText = durationText.trim();

    final isValidDuration = duration.inMinutes >= 30;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValidDuration
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isValidDuration ? Icons.schedule : Icons.warning_outlined,
            color: isValidDuration
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isValidDuration
                  ? 'Duration: $durationText'
                  : 'Minimum duration is 30 minutes',
              style: TextStyle(
                color: isValidDuration
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reservation Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildSummaryRow('Description', _descriptionController.text),
            _buildSummaryRow('Facility', '${_selectedFacility!.name} (${_selectedFacility!.type})'),
            _buildSummaryRow('Date', DateFormat('EEEE, MMM d, y').format(_selectedDate!)),
            _buildSummaryRow('Time', '${_startTime!.format(context)} - ${_endTime!.format(context)}'),
            if (_notesController.text.isNotEmpty)
              _buildSummaryRow('Notes', _notesController.text),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  bool _canShowSummary() {
    return _descriptionController.text.isNotEmpty &&
           _selectedFacility != null &&
           _selectedDate != null &&
           _startTime != null &&
           _endTime != null &&
           _isValidTimeRange();
  }

  bool _isValidTimeRange() {
    if (_startTime == null || _endTime == null) return false;
    
    final startDateTime = DateTime(2023, 1, 1, _startTime!.hour, _startTime!.minute);
    final endDateTime = DateTime(2023, 1, 1, _endTime!.hour, _endTime!.minute);
    final duration = endDateTime.difference(startDateTime);
    
    return !duration.isNegative && duration.inMinutes >= 30;
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: (isStartTime ? _startTime : _endTime) ?? TimeOfDay.now(),
    );
    
    if (time != null) {
      setState(() {
        if (isStartTime) {
          _startTime = time;
          // Auto-set end time to 1 hour later if not set
          if (_endTime == null) {
            final endHour = (time.hour + 1) % 24;
            _endTime = TimeOfDay(hour: endHour, minute: time.minute);
          }
        } else {
          _endTime = time;
        }
      });
    }
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate() || !_canShowSummary()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final viewModel = context.read<ReservationsViewModel>();
      
      // Combine date and times
      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      
      final endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      // Set the times in the view model
      viewModel.setTimeSlot(startDateTime, endDateTime);
      
      // Create the reservation
      await viewModel.createReservation(
        description: _descriptionController.text.trim(),
        facilityId: _selectedFacility!.id,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      if (viewModel.error == null) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reservation created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}