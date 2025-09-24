import '../entities/reservation.dart';
import '../entities/facility.dart';
import '../repositories/reservations_repository.dart';

class GetReservationsUseCase {
  final ReservationsRepository _repository;

  GetReservationsUseCase(this._repository);

  Future<List<Reservation>> call({
    ReservationStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? facilityId,
    int? userId,
  }) async {
    return await _repository.getReservations(
      status: status,
      startDate: startDate,
      endDate: endDate,
      facilityId: facilityId,
      userId: userId,
    );
  }
}

class GetFacilitiesUseCase {
  final ReservationsRepository _repository;

  GetFacilitiesUseCase(this._repository);

  Future<List<Facility>> call() async {
    return await _repository.getFacilities();
  }
}

class CreateReservationUseCase {
  final ReservationsRepository _repository;

  CreateReservationUseCase(this._repository);

  Future<Reservation> call({
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required int facilityId,
    String? notes,
  }) async {
    // Validate input
    if (description.trim().isEmpty) {
      throw ArgumentError('Description cannot be empty');
    }

    if (startTime.isAfter(endTime)) {
      throw ArgumentError('Start time must be before end time');
    }

    if (startTime.isBefore(DateTime.now())) {
      throw ArgumentError('Cannot create reservations in the past');
    }

    // Check minimum duration (30 minutes)
    final duration = endTime.difference(startTime);
    if (duration.inMinutes < 30) {
      throw ArgumentError('Minimum reservation duration is 30 minutes');
    }

    // Check availability
    final isAvailable = await _repository.checkAvailability(
      facilityId: facilityId,
      startTime: startTime,
      endTime: endTime,
    );

    if (!isAvailable) {
      throw Exception('The requested time slot is not available');
    }

    return await _repository.createReservation(
      description: description.trim(),
      startTime: startTime,
      endTime: endTime,
      facilityId: facilityId,
      notes: notes?.trim(),
    );
  }
}

class CancelReservationUseCase {
  final ReservationsRepository _repository;

  CancelReservationUseCase(this._repository);

  Future<bool> call(int reservationId) async {
    if (reservationId <= 0) {
      throw ArgumentError('Invalid reservation ID');
    }

    // Get reservation to check if it can be cancelled
    final reservation = await _repository.getReservationById(reservationId);
    
    // Check if reservation can be cancelled (not in the past, not already cancelled)
    if (reservation.status == ReservationStatus.cancelled) {
      throw Exception('Reservation is already cancelled');
    }

    if (reservation.status == ReservationStatus.completed) {
      throw Exception('Cannot cancel completed reservation');
    }

    if (reservation.startTime.isBefore(DateTime.now())) {
      throw Exception('Cannot cancel past reservations');
    }

    return await _repository.cancelReservation(reservationId);
  }
}

class CheckAvailabilityUseCase {
  final ReservationsRepository _repository;

  CheckAvailabilityUseCase(this._repository);

  Future<bool> call({
    required int facilityId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    if (facilityId <= 0) {
      throw ArgumentError('Invalid facility ID');
    }

    if (startTime.isAfter(endTime)) {
      throw ArgumentError('Start time must be before end time');
    }

    return await _repository.checkAvailability(
      facilityId: facilityId,
      startTime: startTime,
      endTime: endTime,
    );
  }
}