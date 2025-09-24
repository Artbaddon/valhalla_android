class VisitorModel {
  final int id;
  final String name;
  final String documentNumber;
  final String hostName;
  final int? hostId;
  final DateTime? enterDate;
  final DateTime? exitDate;
  final String status;
  final String? vehiclePlate;
  final String? phoneNumber;

  const VisitorModel({
    required this.id,
    required this.name,
    required this.documentNumber,
    required this.hostName,
    this.hostId,
    this.enterDate,
    this.exitDate,
    required this.status,
    this.vehiclePlate,
    this.phoneNumber,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      documentNumber: json['documentNumber'] ?? '',
      hostName: json['hostName'] ?? '',
      hostId: json['hostId'],
      enterDate: json['enterDate'] != null 
          ? DateTime.parse(json['enterDate']) 
          : null,
      exitDate: json['exitDate'] != null 
          ? DateTime.parse(json['exitDate']) 
          : null,
      status: json['status'] ?? 'pending',
      vehiclePlate: json['vehiclePlate'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'documentNumber': documentNumber,
      'hostName': hostName,
      'hostId': hostId,
      'enterDate': enterDate?.toIso8601String(),
      'exitDate': exitDate?.toIso8601String(),
      'status': status,
      'vehiclePlate': vehiclePlate,
      'phoneNumber': phoneNumber,
    };
  }
}