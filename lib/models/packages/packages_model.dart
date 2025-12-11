class Packages {
  final String id;
  final String packageId;
  final String packageType;

  // Campos del paquete
  final String? description;
  final String? senderName;
  final String? carrier; // Cambiado de senderCompany a carrier
  final bool urgent; // Nuevo campo

  // Datos del destinatario
  final int recipientOwnerId;
  final String recipientApartment;
  final String recipientTower;

  // Datos de recepción
  final Map<String, dynamic> receivedByGuard;
  final Map<String, dynamic>? deliveredToOwner;

  // Multimedia y fechas
  final List<String> photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Información enriquecida desde MySQL
  final Map<String, dynamic>? ownerInfo;
  final Map<String, dynamic>? guardInfo;

  const Packages({
    required this.id,
    required this.packageId,
    required this.packageType,
    required this.description,
    required this.senderName,
    required this.carrier,
    required this.urgent,
    required this.recipientOwnerId,
    required this.recipientApartment,
    required this.recipientTower,
    required this.receivedByGuard,
    required this.deliveredToOwner,
    required this.photos,
    required this.createdAt,
    required this.updatedAt,
    required this.ownerInfo,
    required this.guardInfo,
  });

  factory Packages.fromJson(Map<String, dynamic> json) {
    // Helper functions
    String toStr(dynamic v) => v?.toString() ?? '';

    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return v.toInt();
    }

    bool toBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true';
      return false;
    }

    DateTime toDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    List<String> toStringList(dynamic v) {
      if (v is List) return v.map((e) => e?.toString() ?? '').toList();
      return const <String>[];
    }

    Map<String, dynamic> toMap(dynamic v) {
      if (v is Map) return Map<String, dynamic>.from(v);
      return {};
    }

    Map<String, dynamic>? toMapOrNull(dynamic v) {
      if (v == null) return null;
      if (v is Map) return Map<String, dynamic>.from(v);
      return null;
    }

    return Packages(
      id: toStr(json['_id']),
      packageId: toStr(json['package_id']),
      packageType: toStr(json['package_type']),
      description: json['description']?.toString(),
      senderName: json['sender_name']?.toString(),
      carrier: json['carrier']?.toString(),
      urgent: toBool(json['urgent']),
      recipientOwnerId: toInt(json['recipient_owner_id']),
      recipientApartment: toStr(json['recipient_apartment']),
      recipientTower: toStr(json['recipient_tower']),
      receivedByGuard: toMap(json['received_by_guard']),
      deliveredToOwner: toMapOrNull(json['delivered_to_owner']),
      photos: toStringList(json['photos']),
      createdAt: toDate(json['created_at'] ?? json['createdAt']),
      updatedAt: toDate(json['updated_at'] ?? json['updatedAt']),
      ownerInfo: toMapOrNull(json['owner_info']),
      guardInfo: toMapOrNull(json['guard_info']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'package_id': packageId,
      'package_type': packageType,
      'description': description,
      'sender_name': senderName,
      'carrier': carrier,
      'urgent': urgent,
      'recipient_owner_id': recipientOwnerId,
      'recipient_apartment': recipientApartment,
      'recipient_tower': recipientTower,
      'received_by_guard': receivedByGuard,
      'delivered_to_owner': deliveredToOwner,
      'photos': photos,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'owner_info': ownerInfo,
      'guard_info': guardInfo,
    };
  }

  // Getters útiles para acceder a datos comunes
  String? get ownerName => ownerInfo?['name']?.toString();
  String? get ownerEmail => ownerInfo?['email']?.toString();
  String? get guardName => guardInfo?['name']?.toString();
  String? get guardEmail => guardInfo?['email']?.toString();

  int? get guardId => receivedByGuard['guard_id'] is int
      ? receivedByGuard['guard_id']
      : int.tryParse(receivedByGuard['guard_id']?.toString() ?? '');

  DateTime? get receivedAt {
    final date = receivedByGuard['received_at'];
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  // Propiedad computada para estado
  String get status {
    if (deliveredToOwner != null && deliveredToOwner!.isNotEmpty) {
      return 'entregado';
    }
    return 'recibido';
  }

  // Propiedad computada para mostrar información resumida
  String get displayInfo {
    return '$recipientApartment-$recipientTower | $packageType';
  }
}
