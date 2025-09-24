class Visitor {
  final int id;
  final String name;
  final String documentNumber;
  final String hostName;
  final int? hostId;
  final DateTime? enterDate;
  final DateTime? exitDate;
  final String status; // 'active', 'exited', 'pending'
  final String? vehiclePlate;
  final String? phoneNumber;

  const Visitor({
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

  factory Visitor.fromMap(Map<String, dynamic> map) {
    return Visitor(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      documentNumber: map['documentNumber'] ?? '',
      hostName: map['hostName'] ?? '',
      hostId: map['hostId'],
      enterDate: map['enterDate'] != null 
          ? DateTime.parse(map['enterDate']) 
          : null,
      exitDate: map['exitDate'] != null 
          ? DateTime.parse(map['exitDate']) 
          : null,
      status: map['status'] ?? 'pending',
      vehiclePlate: map['vehiclePlate'],
      phoneNumber: map['phoneNumber'],
    );
  }

  Map<String, dynamic> toMap() {
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

  Visitor copyWith({
    int? id,
    String? name,
    String? documentNumber,
    String? hostName,
    int? hostId,
    DateTime? enterDate,
    DateTime? exitDate,
    String? status,
    String? vehiclePlate,
    String? phoneNumber,
  }) {
    return Visitor(
      id: id ?? this.id,
      name: name ?? this.name,
      documentNumber: documentNumber ?? this.documentNumber,
      hostName: hostName ?? this.hostName,
      hostId: hostId ?? this.hostId,
      enterDate: enterDate ?? this.enterDate,
      exitDate: exitDate ?? this.exitDate,
      status: status ?? this.status,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}