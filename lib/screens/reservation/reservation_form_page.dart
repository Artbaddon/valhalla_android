import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:valhalla_android/services/reservation_service.dart';
import 'package:valhalla_android/services/owner_service.dart';
import 'package:valhalla_android/utils/colors.dart';

class ReservationFormPage extends StatefulWidget {
  // Agregamos un parámetro opcional para recibir el owner_id
  final int? preloadedOwnerId;

  const ReservationFormPage({super.key, this.preloadedOwnerId});

  @override
  State<ReservationFormPage> createState() => _ReservationFormPageState();
}

class _ReservationFormPageState extends State<ReservationFormPage> {
  static const Map<int, String> _typeOptions = {
    1: 'Piscina',
    2: 'Gimnasio',
    3: 'Salon de Fiestas',
    4: 'BBQ',
    5: 'Cancha de tennis',
  };
  List<Map<String, dynamic>> owners = [];
  bool loadingOwners = false;
  String? selectedOwnerId;

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.purple,
  );

  final _formKey = GlobalKey<FormState>();
  final _ownerCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _startTimeCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();
  final _endTimeCtrl = TextEditingController();
  final ReservationService _service = ReservationService();

  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int? _selectedType;
  bool _submitting = false;
  bool _isOwnerPreloaded = false; // Para saber si el owner fue pre-cargado

  String _two(int value) => value.toString().padLeft(2, '0');

  DateTime? _combineDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${_two(date.month)}-${_two(date.day)}';

  String _formatTime(TimeOfDay time) =>
      '${_two(time.hour)}:${_two(time.minute)}';

  InputDecoration _inputDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedType = _typeOptions.keys.first;

    // Si viene un owner_id pre-cargado, lo establecemos inmediatamente
    if (widget.preloadedOwnerId != null) {
      _isOwnerPreloaded = true;
      selectedOwnerId = widget.preloadedOwnerId.toString();
      _ownerCtrl.text = selectedOwnerId!;
    }

    _loadOwners();
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

        // Si el owner_id fue pre-cargado, verificamos que exista en la lista
        if (_isOwnerPreloaded && widget.preloadedOwnerId != null) {
          final ownerExists = owners.any(
            (owner) => owner['id'] == widget.preloadedOwnerId,
          );
          if (!ownerExists) {
            // Si no existe, lo agregamos a la lista para mostrar
            owners.insert(0, {
              'id': widget.preloadedOwnerId,
              'name': 'Propietario Actual (ID: ${widget.preloadedOwnerId})',
            });
          }
        }

        // Si hay un selectedOwnerId pero el controller está vacío, lo llenamos
        if (selectedOwnerId != null && _ownerCtrl.text.isEmpty) {
          _ownerCtrl.text = selectedOwnerId!;
        }
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

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    );
  }

  @override
  void dispose() {
    _ownerCtrl.dispose();
    _descriptionCtrl.dispose();
    _startDateCtrl.dispose();
    _startTimeCtrl.dispose();
    _endDateCtrl.dispose();
    _endTimeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BackButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Gestión Zonas Comunes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppColors.purple,
                                  child: Icon(
                                    CupertinoIcons.calendar,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Reservar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.purple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('ID de propietario', style: _labelStyle),
                            const SizedBox(height: 6),

                            // Mostrar campo diferente si el owner está pre-cargado
                            if (_isOwnerPreloaded)
                              AbsorbPointer(
                                // Bloquea la interacción si está pre-cargado
                                absorbing: true,
                                child: TextFormField(
                                  controller: _ownerCtrl,
                                  decoration: _fieldDecoration(
                                    'ID del propietario',
                                  ),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'Requerido'
                                      : null,
                                ),
                              )
                            else
                              DropdownButtonFormField<String>(
                                value: selectedOwnerId,
                                decoration: _fieldDecoration(
                                  'Seleccione un propietario',
                                ),
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

                                  // Estado cargado - mostrar owners
                                  if (!loadingOwners && owners.isNotEmpty)
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
                                onChanged: loadingOwners || owners.isEmpty
                                    ? null
                                    : (value) {
                                        setState(() {
                                          selectedOwnerId = value;
                                          // CORRECCIÓN: Actualizar también el controller
                                          _ownerCtrl.text = value ?? '';
                                        });
                                      },
                              ),

                            const SizedBox(height: 12),
                            Text('Tipo de zona', style: _labelStyle),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              value: _selectedType,
                              decoration: _inputDecoration(
                                'Seleccione el tipo de zona',
                              ),
                              items: _typeOptions.entries
                                  .map(
                                    (entry) => DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(entry.value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _submitting
                                  ? null
                                  : (value) =>
                                        setState(() => _selectedType = value),
                              validator: (value) => value == null
                                  ? 'Seleccione un tipo de zona'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Text('Fecha de inicio', style: _labelStyle),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _startDateCtrl,
                              readOnly: true,
                              decoration: _inputDecoration(
                                'Seleccione la fecha de inicio',
                                suffix: const Icon(CupertinoIcons.calendar),
                              ),
                              onTap: _submitting
                                  ? null
                                  : () => _pickDate(isStart: true),
                              validator: (_) => _startDate == null
                                  ? 'Seleccione la fecha de inicio'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Text('Hora de inicio', style: _labelStyle),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _startTimeCtrl,
                              readOnly: true,
                              decoration: _inputDecoration(
                                'Seleccione la hora de inicio',
                                suffix: const Icon(CupertinoIcons.time),
                              ),
                              onTap: _submitting
                                  ? null
                                  : () => _pickTime(isStart: true),
                              validator: (_) => _startTime == null
                                  ? 'Seleccione la hora de inicio'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Text('Fecha de fin', style: _labelStyle),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _endDateCtrl,
                              readOnly: true,
                              decoration: _inputDecoration(
                                'Seleccione la fecha de finalización',
                                suffix: const Icon(CupertinoIcons.calendar),
                              ),
                              onTap: _submitting
                                  ? null
                                  : () => _pickDate(isStart: false),
                              validator: (_) {
                                if (_endDate == null) {
                                  return 'Seleccione la fecha de fin';
                                }
                                final startDateTime = _combineDateTime(
                                  _startDate,
                                  _startTime,
                                );
                                final endDateTime = _combineDateTime(
                                  _endDate,
                                  _endTime,
                                );
                                if (startDateTime != null &&
                                    endDateTime != null &&
                                    !endDateTime.isAfter(startDateTime)) {
                                  return 'La fecha de fin debe ser posterior al inicio';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            Text('Hora de fin', style: _labelStyle),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _endTimeCtrl,
                              readOnly: true,
                              decoration: _inputDecoration(
                                'Seleccione la hora de finalización',
                                suffix: const Icon(CupertinoIcons.time),
                              ),
                              onTap: _submitting
                                  ? null
                                  : () => _pickTime(isStart: false),
                              validator: (_) {
                                if (_endTime == null) {
                                  return 'Seleccione la hora de fin';
                                }
                                final startDateTime = _combineDateTime(
                                  _startDate,
                                  _startTime,
                                );
                                final endDateTime = _combineDateTime(
                                  _endDate,
                                  _endTime,
                                );
                                if (startDateTime != null &&
                                    endDateTime != null &&
                                    !endDateTime.isAfter(startDateTime)) {
                                  return 'La hora de fin debe ser posterior al inicio';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            Text('Descripción', style: _labelStyle),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _descriptionCtrl,
                              minLines: 3,
                              maxLines: 4,
                              decoration: _inputDecoration(
                                'Añada una descripción',
                              ),
                              enabled: !_submitting,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ingrese una descripción';
                                }
                                if (value.trim().length < 3) {
                                  return 'La descripción es muy corta';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_submitting) ...[
                              const LinearProgressIndicator(),
                              const SizedBox(height: 16),
                            ],

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submitting ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.purple,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text(
                                  _submitting ? 'Guardando...' : 'Reservar',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (selectedDate == null) return;

    setState(() {
      if (isStart) {
        _startDate = selectedDate;
        _startDateCtrl.text = _formatDate(selectedDate);
        if (_endDate != null && _endDate!.isBefore(selectedDate)) {
          _endDate = null;
          _endDateCtrl.clear();
        }
      } else {
        _endDate = selectedDate;
        _endDateCtrl.text = _formatDate(selectedDate);
      }
    });

    _formKey.currentState?.validate();
  }

  Future<void> _pickTime({required bool isStart}) async {
    FocusScope.of(context).unfocus();
    final initialTime = isStart
        ? (_startTime ?? TimeOfDay.now())
        : (_endTime ??
              TimeOfDay(
                hour: (TimeOfDay.now().hour + 1) % 24,
                minute: TimeOfDay.now().minute,
              ));

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (selectedTime == null) return;

    setState(() {
      if (isStart) {
        _startTime = selectedTime;
        _startTimeCtrl.text = _formatTime(selectedTime);
      } else {
        _endTime = selectedTime;
        _endTimeCtrl.text = _formatTime(selectedTime);
      }
    });

    _formKey.currentState?.validate();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      return;
    }

    // CORREGIDO: Manejar ambos casos (pre-cargado y seleccionado)
    int ownerId;
    if (_isOwnerPreloaded) {
      // Usar el owner_id pre-cargado directamente
      ownerId = widget.preloadedOwnerId!;
    } else {
      // Usar selectedOwnerId en lugar de _ownerCtrl.text para mayor seguridad
      if (selectedOwnerId == null || selectedOwnerId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione un propietario')),
        );
        return;
      }

      try {
        ownerId = int.parse(selectedOwnerId!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID de propietario inválido')),
        );
        return;
      }
    }

    final startDateTime = _combineDateTime(_startDate, _startTime)!;
    final endDateTime = _combineDateTime(_endDate, _endTime)!;
    final typeId = _selectedType ?? _typeOptions.keys.first;
    final description = _descriptionCtrl.text.trim();

    final now = DateTime.now();
    if (startDateTime.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de inicio debe ser futura.')),
      );
      return;
    }

    if (!endDateTime.isAfter(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de fin debe ser posterior al inicio.'),
        ),
      );
      return;
    }

    final payload = {
      'owner_id': ownerId,
      'type_id': typeId,
      'start_date': startDateTime.toIso8601String(),
      'end_date': endDateTime.toIso8601String(),
      'description': description.isEmpty ? null : description,
    };

    setState(() => _submitting = true);
    try {
      await _service.create(payload);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Reserva creada correctamente')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      String message = 'Error al crear la reserva';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['error'] is String) {
          message = data['error'] as String;
        } else if (e.message != null) {
          message = e.message!;
        }
      } else {
        message = e.toString();
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
