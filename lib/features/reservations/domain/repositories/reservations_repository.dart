import '../entities/reservation.dart';
import '../entities/facility.dart';

abstract class ReservationsRepository {
  /// Get all reservations with optional filters
  Future<List<Reservation>> getReservations({
    ReservationStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? facilityId,
    int? userId,
  });

  /// Get reservation by ID
  Future<Reservation> getReservationById(int id);

  /// Create a new reservation
  Future<Reservation> createReservation({
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required int facilityId,
    String? notes,
  });

  /// Update reservation
  Future<Reservation> updateReservation(Reservation reservation);

  /// Cancel reservation
  Future<bool> cancelReservation(int reservationId);

  /// Get all available facilities
  Future<List<Facility>> getFacilities();

  /// Get facility by ID
  Future<Facility> getFacilityById(int id);

  /// Check availability for a facility on a specific date and time
  Future<bool> checkAvailability({
    required int facilityId,
    required DateTime startTime,
    required DateTime endTime,
  });

  /// Get available time slots for a facility on a specific date
  Future<List<TimeSlot>> getAvailableSlots({
    required int facilityId,
    required DateTime date,
  });
}