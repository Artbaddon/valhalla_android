class ParkingSpot {
  final int id;
  final String number;
  final String type; // 'resident', 'visitor'
  final String status; // 'occupied', 'available', 'maintenance'
  final String? ownerName;
  final String? ownerEmail;
  final int? ownerId;
  final DateTime? occupiedSince;
  final String? vehiclePlate;
  final String? vehicleModel;

  const ParkingSpot({
    required this.id,
    required this.number,
    required this.type,
    required this.status,
    this.ownerName,
    this.ownerEmail,
    this.ownerId,
    this.occupiedSince,
    this.vehiclePlate,
    this.vehicleModel,
  });

  factory ParkingSpot.fromMap(Map<String, dynamic> map) {
    return ParkingSpot(
      id: map['id'] ?? 0,
      number: map['number'] ?? '',
      type: map['type'] ?? 'visitor',
      status: map['status'] ?? 'available',
      ownerName: map['ownerName'],
      ownerEmail: map['ownerEmail'],
      ownerId: map['ownerId'],
      occupiedSince: map['occupiedSince'] != null 
          ? DateTime.parse(map['occupiedSince']) 
          : null,
      vehiclePlate: map['vehiclePlate'],
      vehicleModel: map['vehicleModel'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'type': type,
      'status': status,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'ownerId': ownerId,
      'occupiedSince': occupiedSince?.toIso8601String(),
      'vehiclePlate': vehiclePlate,
      'vehicleModel': vehicleModel,
    };
  }

  ParkingSpot copyWith({
    int? id,
    String? number,
    String? type,
    String? status,
    String? ownerName,
    String? ownerEmail,
    int? ownerId,
    DateTime? occupiedSince,
    String? vehiclePlate,
    String? vehicleModel,
  }) {
    return ParkingSpot(
      id: id ?? this.id,
      number: number ?? this.number,
      type: type ?? this.type,
      status: status ?? this.status,
      ownerName: ownerName ?? this.ownerName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerId: ownerId ?? this.ownerId,
      occupiedSince: occupiedSince ?? this.occupiedSince,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleModel: vehicleModel ?? this.vehicleModel,
    );
  }
}