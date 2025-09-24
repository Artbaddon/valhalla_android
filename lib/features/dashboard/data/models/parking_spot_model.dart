import '../../domain/entities/parking_spot.dart';

class ParkingSpotModel {
  final int id;
  final String number;
  final String type;
  final String status;
  final String? ownerName;
  final String? ownerEmail;
  final int? ownerId;
  final DateTime? occupiedSince;
  final String? vehiclePlate;
  final String? vehicleModel;

  const ParkingSpotModel({
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

  factory ParkingSpotModel.fromJson(Map<String, dynamic> json) {
    return ParkingSpotModel(
      id: json['id'] ?? 0,
      number: json['number'] ?? '',
      type: json['type'] ?? 'visitor',
      status: json['status'] ?? 'available',
      ownerName: json['ownerName'],
      ownerEmail: json['ownerEmail'],
      ownerId: json['ownerId'],
      occupiedSince: json['occupiedSince'] != null 
          ? DateTime.parse(json['occupiedSince']) 
          : null,
      vehiclePlate: json['vehiclePlate'],
      vehicleModel: json['vehicleModel'],
    );
  }

  Map<String, dynamic> toJson() {
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
}

extension ParkingSpotModelExtensions on ParkingSpotModel {
  ParkingSpot toEntity() {
    return ParkingSpot(
      id: id,
      number: number,
      type: type,
      status: status,
      ownerName: ownerName,
      ownerEmail: ownerEmail,
      ownerId: ownerId,
      occupiedSince: occupiedSince,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
    );
  }
}

extension ParkingSpotExtensions on ParkingSpot {
  ParkingSpotModel toModel() {
    return ParkingSpotModel(
      id: id,
      number: number,
      type: type,
      status: status,
      ownerName: ownerName,
      ownerEmail: ownerEmail,
      ownerId: ownerId,
      occupiedSince: occupiedSince,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
    );
  }
}