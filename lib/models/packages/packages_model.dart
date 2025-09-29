class Packages {
  // Mongo-style id comes as string ("_id")
  final String id;

  final String packageId;
  final String packageType;

  final String? status;
  final String? description;
  final String? senderName;
  final String? senderCompany;
  final String? size;
  final double? weight;
  final String? guardNotes;
  final String? deliveryNotes;
  final String? recipientSignature;

  final int? recipientOwnerId;
  final String recipientApartment;
  final String recipientTower;

  final List<String> photos;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Raw owner_info shape is unknown in sample, keep as map
  final Map<String, dynamic>? ownerInfo;

  const Packages({
    required this.id,
    required this.packageId,
    required this.packageType,
  required this.status,
  required this.description,
  required this.senderName,
  required this.senderCompany,
  required this.size,
  required this.weight,
  required this.guardNotes,
  required this.deliveryNotes,
  required this.recipientSignature,
    required this.recipientOwnerId,
    required this.recipientApartment,
    required this.recipientTower,
    required this.photos,
    required this.createdAt,
    required this.updatedAt,
    required this.ownerInfo,
  });

  factory Packages.fromJson(Map<String, dynamic> json) {
    int? toIntOrNull(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    double? toDoubleOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    String toStr(dynamic v) => v?.toString() ?? '';

    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    List<String> toStringList(dynamic v) {
      if (v is List) return v.map((e) => e?.toString() ?? '').toList();
      return const <String>[];
    }

    Map<String, dynamic>? toMapOrNull(dynamic v) {
      if (v is Map) return Map<String, dynamic>.from(v);
      return null;
    }

    return Packages(
      id: toStr(json['_id']),
      packageId: toStr(json['package_id']),
      packageType: toStr(json['package_type']),
    status: json.containsKey('status') ? toStr(json['status']) : null,
    description: json.containsKey('description') ? toStr(json['description']) : null,
    senderName: json.containsKey('sender_name') ? toStr(json['sender_name']) : null,
    senderCompany: json.containsKey('sender_company') ? toStr(json['sender_company']) : null,
    size: json.containsKey('size') ? toStr(json['size']) : null,
    weight: toDoubleOrNull(json['weight']),
    guardNotes: json.containsKey('guard_notes') ? toStr(json['guard_notes']) : null,
    deliveryNotes: json.containsKey('delivery_notes') ? toStr(json['delivery_notes']) : null,
    recipientSignature: json.containsKey('recipient_signature')
      ? toStr(json['recipient_signature'])
      : null,
      recipientOwnerId: toIntOrNull(json['recipient_owner_id']),
      recipientApartment: toStr(json['recipient_apartment']),
      recipientTower: toStr(json['recipient_tower']),
      photos: toStringList(json['photos']),
      createdAt: toDate(json['created_at'] ?? json['createdAt']),
      updatedAt: toDate(json['updated_at'] ?? json['updatedAt']),
      ownerInfo: toMapOrNull(json['owner_info']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'package_id': packageId,
      'package_type': packageType,
  'status': status,
  'description': description,
  'sender_name': senderName,
  'sender_company': senderCompany,
  'size': size,
  'weight': weight,
  'guard_notes': guardNotes,
  'delivery_notes': deliveryNotes,
  'recipient_signature': recipientSignature,
      'recipient_owner_id': recipientOwnerId,
      'recipient_apartment': recipientApartment,
      'recipient_tower': recipientTower,
      'photos': photos,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'owner_info': ownerInfo,
    };
  }
}
