import '../../domain/entities/reservation.dart';
import '../../domain/entities/facility.dart';
import '../../domain/repositories/reservations_repository.dart';
import '../datasources/reservations_remote_data_source.dart';
import '../models/reservation_model.dart';
import '../models/facility_model.dart';

class ReservationsRepositoryImpl implements ReservationsRepository {
  final ReservationsRemoteDataSource remoteDataSource;

  ReservationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Reservation>> getReservations({
    ReservationStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? facilityId,
    int? userId,
  }) async {
    final models = await remoteDataSource.getReservations(userId ?? 0);
    
    // Apply filters if provided
    List<Reservation> reservations = models.map((model) => model.toEntity()).toList();
    
    if (status != null) {
      reservations = reservations.where((r) => r.status == status).toList();
    }
    
    if (startDate != null) {
      reservations = reservations.where((r) => r.startTime.isAfter(startDate) || r.startTime.isAtSameMomentAs(startDate)).toList();
    }
    
    if (endDate != null) {
      reservations = reservations.where((r) => r.endTime.isBefore(endDate) || r.endTime.isAtSameMomentAs(endDate)).toList();
    }
    
    if (facilityId != null) {
      reservations = reservations.where((r) => r.facilityId == facilityId).toList();
    }
    
    if (userId != null) {
      reservations = reservations.where((r) => r.userId == userId).toList();
    }
    
    return reservations;
  }

  @override
  Future<Reservation> getReservationById(int id) async {
    // For now, get all reservations and find by ID
    // In a real implementation, you'd have a specific endpoint
    final models = await remoteDataSource.getAllReservations();
    final model = models.firstWhere(
      (m) => m.id == id,
      orElse: () => throw Exception('Reservation not found'),
    );
    return model.toEntity();
  }

  @override
  Future<Reservation> createReservation({
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required int facilityId,
    String? notes,
  }) async {
    final reservationData = {
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'facilityId': facilityId,
      'notes': notes,
    };

    final model = await remoteDataSource.createReservation(reservationData);
    return model.toEntity();
  }

  @override
  Future<Reservation> updateReservation(Reservation reservation) async {
    final reservationData = reservation.toModel().toJson();
    final model = await remoteDataSource.createReservation(reservationData);
    return model.toEntity();
  }

  @override
  Future<bool> cancelReservation(int reservationId) async {
    return await remoteDataSource.cancelReservation(reservationId);
  }

  @override
  Future<List<Facility>> getFacilities() async {
    final models = await remoteDataSource.getFacilities();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Facility> getFacilityById(int id) async {
    final model = await remoteDataSource.getFacility(id);
    return model.toEntity();
  }

  @override
  Future<bool> checkAvailability({
    required int facilityId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    return await remoteDataSource.checkAvailability(facilityId, startTime, endTime);
  }

  @override
  Future<List<TimeSlot>> getAvailableSlots({
    required int facilityId,
    required DateTime date,
  }) async {
    final slotsData = await remoteDataSource.getAvailableSlots(facilityId, date);
    
    return slotsData.map((slotData) => TimeSlot(
      startTime: slotData['startTime'] ?? '09:00',
      endTime: slotData['endTime'] ?? '18:00',
      isAvailable: slotData['isAvailable'] ?? true,
    )).toList();
  }
}