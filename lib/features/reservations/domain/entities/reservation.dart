enum ReservationStatus {
  pending,
  confirmed,
  active,
  completed,
  cancelled,
}

class Reservation {
  final int id;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final ReservationStatus status;
  final String facilityName; // e.g., "BBQ", "Piscina", "Gimnasio"
  final String facilityType; // Zone type
  final int facilityId;
  final int userId;
  final String userName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;

  const Reservation({
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

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'] ?? 0,
      description: map['description'] ?? '',
      startTime: map['startTime'] != null 
          ? DateTime.parse(map['startTime']) 
          : DateTime.now(),
      endTime: map['endTime'] != null 
          ? DateTime.parse(map['endTime']) 
          : DateTime.now().add(const Duration(hours: 1)),
      status: _statusFromString(map['status'] ?? 'pending'),
      facilityName: map['facilityName'] ?? '',
      facilityType: map['facilityType'] ?? '',
      facilityId: map['facilityId'] ?? 0,
      userId: map['userId'] ?? 0,
      userName: map['userName'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status.name,
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

  Reservation copyWith({
    int? id,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    ReservationStatus? status,
    String? facilityName,
    String? facilityType,
    int? facilityId,
    int? userId,
    String? userName,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return Reservation(
      id: id ?? this.id,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      facilityName: facilityName ?? this.facilityName,
      facilityType: facilityType ?? this.facilityType,
      facilityId: facilityId ?? this.facilityId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
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

  String get statusDisplayName {
    switch (status) {
      case ReservationStatus.pending:
        return 'Pendiente';
      case ReservationStatus.confirmed:
        return 'Confirmada';
      case ReservationStatus.active:
        return 'Activa';
      case ReservationStatus.completed:
        return 'Completada';
      case ReservationStatus.cancelled:
        return 'Cancelada';
    }
  }

  String get durationFormatted {
    final duration = endTime.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}min';
    }
  }

  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isActive => status == ReservationStatus.active && 
                      DateTime.now().isAfter(startTime) && 
                      DateTime.now().isBefore(endTime);
  bool get isPast => endTime.isBefore(DateTime.now());
}