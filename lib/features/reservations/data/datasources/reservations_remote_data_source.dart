import 'package:dio/dio.dart';
import '../models/reservation_model.dart';
import '../models/facility_model.dart';

abstract class ReservationsRemoteDataSource {
  Future<List<ReservationModel>> getReservations(int userId);
  Future<List<ReservationModel>> getUserReservations(int userId);
  Future<List<ReservationModel>> getAllReservations();
  Future<ReservationModel> createReservation(Map<String, dynamic> reservationData);
  Future<bool> cancelReservation(int reservationId);
  Future<List<FacilityModel>> getFacilities();
  Future<FacilityModel> getFacility(int facilityId);
  Future<bool> checkAvailability(int facilityId, DateTime startTime, DateTime endTime);
  Future<List<Map<String, dynamic>>> getAvailableSlots(int facilityId, DateTime date);
}

class ReservationsRemoteDataSourceImpl implements ReservationsRemoteDataSource {
  final Dio dio;

  ReservationsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ReservationModel>> getReservations(int userId) async {
    try {
      final response = await dio.get('/reservations', queryParameters: {
        'userId': userId,
      });
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => ReservationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching reservations: $e');
    }
  }

  @override
  Future<List<ReservationModel>> getUserReservations(int userId) async {
    try {
      final response = await dio.get('/reservations/user/$userId');
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => ReservationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching user reservations: $e');
    }
  }

  @override
  Future<List<ReservationModel>> getAllReservations() async {
    try {
      final response = await dio.get('/reservations/all');
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => ReservationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching all reservations: $e');
    }
  }

  @override
  Future<ReservationModel> createReservation(Map<String, dynamic> reservationData) async {
    try {
      final response = await dio.post('/reservations', data: reservationData);
      return ReservationModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException) {
        switch (e.response?.statusCode) {
          case 400:
            throw Exception('Invalid reservation data: ${e.response?.data['message'] ?? 'Bad request'}');
          case 409:
            throw Exception('Time slot not available: ${e.response?.data['message'] ?? 'Conflict'}');
          case 422:
            throw Exception('Validation error: ${e.response?.data['message'] ?? 'Invalid data'}');
          default:
            throw Exception('Error creating reservation: ${e.response?.data['message'] ?? e.message}');
        }
      }
      throw Exception('Error creating reservation: $e');
    }
  }

  @override
  Future<bool> cancelReservation(int reservationId) async {
    try {
      final response = await dio.patch('/reservations/$reservationId/cancel');
      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException) {
        switch (e.response?.statusCode) {
          case 404:
            throw Exception('Reservation not found');
          case 400:
            throw Exception('Cannot cancel reservation: ${e.response?.data['message'] ?? 'Invalid request'}');
          default:
            throw Exception('Error cancelling reservation: ${e.response?.data['message'] ?? e.message}');
        }
      }
      throw Exception('Error cancelling reservation: $e');
    }
  }

  @override
  Future<List<FacilityModel>> getFacilities() async {
    try {
      final response = await dio.get('/facilities');
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => FacilityModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching facilities: $e');
    }
  }

  @override
  Future<FacilityModel> getFacility(int facilityId) async {
    try {
      final response = await dio.get('/facilities/$facilityId');
      return FacilityModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        throw Exception('Facility not found');
      }
      throw Exception('Error fetching facility: $e');
    }
  }

  @override
  Future<bool> checkAvailability(int facilityId, DateTime startTime, DateTime endTime) async {
    try {
      final response = await dio.post('/facilities/$facilityId/check-availability', data: {
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      });
      
      return response.data['available'] ?? false;
    } catch (e) {
      throw Exception('Error checking availability: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailableSlots(int facilityId, DateTime date) async {
    try {
      final response = await dio.get('/facilities/$facilityId/available-slots', queryParameters: {
        'date': date.toIso8601String().split('T')[0], // Send only the date part
      });
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error fetching available slots: $e');
    }
  }
}