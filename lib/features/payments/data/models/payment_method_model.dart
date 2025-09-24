import '../../domain/entities/payment_method.dart';

class PaymentMethodModel {
  final int id;
  final String type;
  final String name;
  final String cardNumber;
  final String? expiryDate;
  final String? holderName;
  final String? bankName;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final int userId;

  const PaymentMethodModel({
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

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'credit_card',
      name: json['name'] ?? '',
      cardNumber: json['cardNumber'] ?? '',
      expiryDate: json['expiryDate'],
      holderName: json['holderName'],
      bankName: json['bankName'],
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      userId: json['userId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
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
}

extension PaymentMethodModelExtensions on PaymentMethodModel {
  PaymentMethod toEntity() {
    return PaymentMethod(
      id: id,
      type: type,
      name: name,
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      holderName: holderName,
      bankName: bankName,
      isDefault: isDefault,
      isActive: isActive,
      createdAt: createdAt,
      userId: userId,
    );
  }
}

extension PaymentMethodExtensions on PaymentMethod {
  PaymentMethodModel toModel() {
    return PaymentMethodModel(
      id: id,
      type: type,
      name: name,
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      holderName: holderName,
      bankName: bankName,
      isDefault: isDefault,
      isActive: isActive,
      createdAt: createdAt,
      userId: userId,
    );
  }
}