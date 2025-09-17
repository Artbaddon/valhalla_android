class Parking {
  final int id;            // keep non-nullable; default to 0 if missing
  final String number;     // default ''
  final String status;     // default ''
  final int? userId;       // can be null when unassigned
  final String parkingType;// default ''
  final String vehicleType;// default ''

  Parking({
    required this.id,
    required this.number,
    required this.status,
    required this.userId,
    required this.parkingType,
    required this.vehicleType,
  });

  factory Parking.fromJson(Map<String, dynamic> json) {
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

    String toStr(dynamic v) => v?.toString() ?? '';

    return Parking(
      id: toInt(json['Parking_id'] ?? json['id'], defaultValue: 0),
      number: toStr(json['Parking_number'] ?? json['number']),
      status: toStr(json['Parking_status_name'] ?? json['status']),
      userId: toIntOrNull(json['User_ID_FK'] ?? json['user_id'] ?? json['userId']),
      parkingType: toStr(json['Parking_type_name'] ?? json['parking_type']),
      vehicleType: toStr(json['Vehicle_type_name'] ?? json['vehicle_type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Parking_id': id,
      'Parking_number': number,
      'Parking_status_name': status,
      'User_ID_FK': userId,
      'Parking_type_name': parkingType,
      'Vehicle_type_name': vehicleType,
    };
  }
}
