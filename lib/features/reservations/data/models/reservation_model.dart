import '../../domain/entities/reservation.dart';

class ReservationModel {
  final int id;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String facilityName;
  final String facilityType;
  final int facilityId;
  final int userId;
  final String userName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;

  const ReservationModel({
    required this.id,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.facilityName,
    required this.facilityType,
    required this.facilityId,
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.updatedAt,
    this.notes,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      startTime: json['startTime'] != null 
          ? DateTime.parse(json['startTime']) 
          : DateTime.now(),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime']) 
          : DateTime.now().add(const Duration(hours: 1)),
      status: json['status'] ?? 'pending',
      facilityName: json['facilityName'] ?? '',
      facilityType: json['facilityType'] ?? '',
      facilityId: json['facilityId'] ?? 0,
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
      'facilityName': facilityName,
      'facilityType': facilityType,
      'facilityId': facilityId,
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}

extension ReservationModelExtensions on ReservationModel {
  Reservation toEntity() {
    return Reservation(
      id: id,
      description: description,
      startTime: startTime,
      endTime: endTime,
      status: _statusFromString(status),
      facilityName: facilityName,
      facilityType: facilityType,
      facilityId: facilityId,
      userId: userId,
      userName: userName,
      createdAt: createdAt,
      updatedAt: updatedAt,
      notes: notes,
    );
  }

  static ReservationStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ReservationStatus.pending;
      case 'confirmed':
        return ReservationStatus.confirmed;
      case 'active':
        return ReservationStatus.active;
      case 'completed':
        return ReservationStatus.completed;
      case 'cancelled':
        return ReservationStatus.cancelled;
      default:
        return ReservationStatus.pending;
    }
  }
}

extension ReservationEntityExtensions on Reservation {
  ReservationModel toModel() {
    return ReservationModel(
      id: id,
      description: description,
      startTime: startTime,
      endTime: endTime,
      status: status.name,
      facilityName: facilityName,
      facilityType: facilityType,
      facilityId: facilityId,
      userId: userId,
      userName: userName,
      createdAt: createdAt,
      updatedAt: updatedAt,
      notes: notes,
    );
  }
}