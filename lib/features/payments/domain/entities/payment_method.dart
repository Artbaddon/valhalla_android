class PaymentMethod {
  final int id;
  final String type; // 'credit_card', 'debit_card', 'bank_account'
  final String name; // Display name like "Visa *1234"
  final String cardNumber; // Masked number like "**** **** **** 1234"
  final String? expiryDate; // MM/YY format
  final String? holderName;
  final String? bankName;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final int userId;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.cardNumber,
    this.expiryDate,
    this.holderName,
    this.bankName,
    required this.isDefault,
    required this.isActive,
    required this.createdAt,
    required this.userId,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'] ?? 0,
      type: map['type'] ?? 'credit_card',
      name: map['name'] ?? '',
      cardNumber: map['cardNumber'] ?? '',
      expiryDate: map['expiryDate'],
      holderName: map['holderName'],
      bankName: map['bankName'],
      isDefault: map['isDefault'] ?? false,
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      userId: map['userId'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'holderName': holderName,
      'bankName': bankName,
      'isDefault': isDefault,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  PaymentMethod copyWith({
    int? id,
    String? type,
    String? name,
    String? cardNumber,
    String? expiryDate,
    String? holderName,
    String? bankName,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    int? userId,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      holderName: holderName ?? this.holderName,
      bankName: bankName ?? this.bankName,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  String get displayName {
    if (type == 'bank_account') {
      return bankName ?? name;
    }
    return name;
  }

  String get cardType {
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5')) return 'Mastercard';
    if (cardNumber.startsWith('3')) return 'American Express';
    return 'Tarjeta';
  }
}