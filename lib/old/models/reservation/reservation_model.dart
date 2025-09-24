// Reservation models adapted to backend keys (Reservation_*)

enum ReservationStatus {
  pending,
  confirmed,
  active,
  completed,
  cancelled,
  unknown,
}

class Reservation {
  // IDs
  final int id; // Reservation_id
  final int? typeId; // Reservation_type_FK_ID
  final int? statusId; // Reservation_status_FK_ID
  final int? facilityId; // Facility_FK_ID
  final int? ownerId; // Owner_FK_ID / Owner_id

  // Times
  final DateTime? startTime; // Reservation_start_time
  final DateTime? endTime; // Reservation_end_time
  final DateTime? createdAt; // createdAt/created_at
  final DateTime? updatedAt; // updatedAt/updated_at

  // Text fields
  final String description; // Reservation_description
  final String statusName; // Reservation_status_name (e.g., "Pending")
  final String typeName; // Reservation_type_name (e.g., "Room")
  final String ownerName; // owner_name

  // Derived
  final ReservationStatus status; // mapped from statusName

  const Reservation({
    required this.id,
    this.typeId,
    this.statusId,
    this.facilityId,
    this.ownerId,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.updatedAt,
    this.description = '',
    this.statusName = '',
    this.typeName = '',
    this.ownerName = '',
    this.status = ReservationStatus.unknown,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, {int defaultValue = 0}) {
      if (v == null) return defaultValue;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? defaultValue;
    }

    int? toIntOrNull(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    String toStr(dynamic v) => v?.toString() ?? '';

    final statusName = toStr(
      json['Reservation_status_name'] ?? json['status_name'] ?? json['status'],
    );
    final typeName = toStr(json['Reservation_type_name'] ?? json['type_name']);

    return Reservation(
      id: toInt(json['Reservation_id'] ?? json['id'], defaultValue: 0),
      typeId: toIntOrNull(json['Reservation_type_FK_ID'] ?? json['type_id']),
      statusId: toIntOrNull(
        json['Reservation_status_FK_ID'] ?? json['status_id'],
      ),
      startTime: toDate(json['Reservation_start_time'] ?? json['start_time']),
      endTime: toDate(json['Reservation_end_time'] ?? json['end_time']),
      facilityId: toIntOrNull(json['Facility_FK_ID'] ?? json['facility_id']),
      description: toStr(
        json['Reservation_description'] ?? json['description'],
      ),
      ownerId: toIntOrNull(
        json['Owner_FK_ID'] ?? json['Owner_id'] ?? json['owner_id'],
      ),
      createdAt: toDate(json['createdAt'] ?? json['created_at']),
      updatedAt: toDate(json['updatedAt'] ?? json['updated_at']),
      statusName: statusName,
      typeName: typeName,
      ownerName: toStr(json['owner_name']),
      status: _statusFromName(statusName),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Reservation_id': id,
      'Reservation_type_FK_ID': typeId,
      'Reservation_status_FK_ID': statusId,
      'Reservation_start_time': startTime?.toIso8601String(),
      'Reservation_end_time': endTime?.toIso8601String(),
      'Facility_FK_ID': facilityId,
      'Reservation_description': description,
      'Owner_FK_ID': ownerId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'Reservation_status_name': statusName,
      'Reservation_type_name': typeName,
      'owner_name': ownerName,
    };
  }

  static ReservationStatus _statusFromName(String name) {
    switch (name.toLowerCase()) {
      case 'pending':
        return ReservationStatus.pending;
      case 'confirmed':
        return ReservationStatus.confirmed;
      case 'active':
        return ReservationStatus.active;
      case 'completed':
        return ReservationStatus.completed;
      case 'cancelled':
      case 'canceled':
        return ReservationStatus.cancelled;
      default:
        return ReservationStatus.unknown;
    }
  }
}

// Keep Property if you still need it for other endpoints.
// If this file was only for reservations, you can leave Property as-is or move it.
// ...existing code...
