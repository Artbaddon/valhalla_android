import 'package:flutter/material.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/facility.dart';
import '../../domain/usecases/reservations_usecases.dart';

class ReservationsViewModel extends ChangeNotifier {
  final GetReservationsUseCase getReservationsUseCase;
  final GetFacilitiesUseCase getFacilitiesUseCase;
  final CreateReservationUseCase createReservationUseCase;
  final CancelReservationUseCase cancelReservationUseCase;
  final CheckAvailabilityUseCase checkAvailabilityUseCase;

  ReservationsViewModel({
    required this.getReservationsUseCase,
    required this.getFacilitiesUseCase,
    required this.createReservationUseCase,
    required this.cancelReservationUseCase,
    required this.checkAvailabilityUseCase,
  });

  // State management
  List<Reservation> _reservations = [];
  List<Facility> _facilities = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();
  Facility? _selectedFacility;
  DateTime? _selectedStartTime;
  DateTime? _selectedEndTime;

  // Getters
  List<Reservation> get reservations => _reservations;
  List<Facility> get facilities => _facilities;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;
  Facility? get selectedFacility => _selectedFacility;
  DateTime? get selectedStartTime => _selectedStartTime;
  DateTime? get selectedEndTime => _selectedEndTime;

  // Computed getters
  List<Reservation> get upcomingReservations => 
      _reservations.where((r) => r.isUpcoming).toList();

  List<Reservation> get pastReservations => 
      _reservations.where((r) => r.isPast).toList();

  List<Reservation> get todaysReservations =>
      _reservations.where((r) => 
        r.startTime.year == DateTime.now().year &&
        r.startTime.month == DateTime.now().month &&
        r.startTime.day == DateTime.now().day
      ).toList();

  List<Facility> get availableFacilities =>
      _facilities.where((f) => f.isActive).toList();

  bool get canCreateReservation =>
      _selectedFacility != null &&
      _selectedStartTime != null &&
      _selectedEndTime != null &&
      _selectedStartTime!.isBefore(_selectedEndTime!);

  // Methods
  Future<void> loadReservations({
    ReservationStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? facilityId,
    int? userId,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final reservations = await getReservationsUseCase.call(
        status: status,
        startDate: startDate,
        endDate: endDate,
        facilityId: facilityId,
        userId: userId,
      );

      _reservations = reservations;
      notifyListeners();
    } catch (e) {
      _setError('Error loading reservations: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadFacilities() async {
    _setLoading(true);
    _setError(null);

    try {
      final facilities = await getFacilitiesUseCase.call();
      _facilities = facilities;
      notifyListeners();
    } catch (e) {
      _setError('Error loading facilities: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createReservation({
    required String description,
    required int facilityId,
    String? notes,
  }) async {
    if (!canCreateReservation || _selectedStartTime == null || _selectedEndTime == null) {
      _setError('Invalid reservation data');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final reservation = await createReservationUseCase.call(
        description: description,
        startTime: _selectedStartTime!,
        endTime: _selectedEndTime!,
        facilityId: facilityId,
        notes: notes,
      );

      _reservations.add(reservation);
      _clearSelection();
      notifyListeners();
    } catch (e) {
      _setError('Error creating reservation: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cancelReservation(int reservationId) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await cancelReservationUseCase.call(reservationId);
      
      if (success) {
        _reservations.removeWhere((r) => r.id == reservationId);
        notifyListeners();
      } else {
        _setError('Failed to cancel reservation');
      }
    } catch (e) {
      _setError('Error cancelling reservation: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> checkAvailability({
    required int facilityId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      return await checkAvailabilityUseCase.call(
        facilityId: facilityId,
        startTime: startTime,
        endTime: endTime,
      );
    } catch (e) {
      _setError('Error checking availability: $e');
      return false;
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _clearTimeSelection();
    notifyListeners();
  }

  void setSelectedFacility(Facility? facility) {
    _selectedFacility = facility;
    _clearTimeSelection();
    notifyListeners();
  }

  void setSelectedStartTime(DateTime? startTime) {
    _selectedStartTime = startTime;
    notifyListeners();
  }

  void setSelectedEndTime(DateTime? endTime) {
    _selectedEndTime = endTime;
    notifyListeners();
  }

  void setTimeSlot(DateTime startTime, DateTime endTime) {
    _selectedStartTime = startTime;
    _selectedEndTime = endTime;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  void _clearSelection() {
    _selectedFacility = null;
    _selectedStartTime = null;
    _selectedEndTime = null;
  }

  void _clearTimeSelection() {
    _selectedStartTime = null;
    _selectedEndTime = null;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Filter methods
  List<Reservation> getReservationsByStatus(ReservationStatus status) {
    return _reservations.where((r) => r.status == status).toList();
  }

  List<Reservation> getReservationsByFacility(int facilityId) {
    return _reservations.where((r) => r.facilityId == facilityId).toList();
  }

  List<Reservation> getReservationsByDate(DateTime date) {
    return _reservations.where((r) =>
        r.startTime.year == date.year &&
        r.startTime.month == date.month &&
        r.startTime.day == date.day).toList();
  }

  // Refresh data
  Future<void> refresh() async {
    await Future.wait([
      loadReservations(),
      loadFacilities(),
    ]);
  }
}