// Reservation models
class Reservation {
  final String id;
  final String userId;
  final String propertyId;
  final DateTime startDate;
  final DateTime endDate;
  final ReservationStatus status;
  final double totalAmount;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      userId: json['user_id'],
      propertyId: json['property_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: ReservationStatus.values.firstWhere((e) => e.name == json['status']),
      totalAmount: json['total_amount'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

enum ReservationStatus {
  pending,
  confirmed,
  active,
  completed,
  cancelled,
}

class Property {
  final String id;
  final String name;
  final String address;
  final double pricePerNight;
  final List<String> amenities;
  final String ownerId;

  Property({
    required this.id,
    required this.name,
    required this.address,
    required this.pricePerNight,
    required this.amenities,
    required this.ownerId,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      pricePerNight: json['price_per_night'].toDouble(),
      amenities: List<String>.from(json['amenities']),
      ownerId: json['owner_id'],
    );
  }
}