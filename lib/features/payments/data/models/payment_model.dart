import '../../domain/entities/payment.dart';

class PaymentModel {
  final int id;
  final String description;
  final double amount;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? transactionId;
  final String? reference;
  final int userId;
  final String userName;
  final String category;

  const PaymentModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    this.paidAt,
    this.transactionId,
    this.reference,
    required this.userId,
    required this.userName,
    required this.category,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? 'credit_card',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      paidAt: json['paidAt'] != null 
          ? DateTime.parse(json['paidAt']) 
          : null,
      transactionId: json['transactionId'],
      reference: json['reference'],
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      category: json['category'] ?? 'parking',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'status': status,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'transactionId': transactionId,
      'reference': reference,
      'userId': userId,
      'userName': userName,
      'category': category,
    };
  }
}

extension PaymentModelExtensions on PaymentModel {
  Payment toEntity() {
    return Payment(
      id: id,
      description: description,
      amount: amount,
      status: status,
      paymentMethod: paymentMethod,
      createdAt: createdAt,
      paidAt: paidAt,
      transactionId: transactionId,
      reference: reference,
      userId: userId,
      userName: userName,
      category: category,
    );
  }
}

extension PaymentExtensions on Payment {
  PaymentModel toModel() {
    return PaymentModel(
      id: id,
      description: description,
      amount: amount,
      status: status,
      paymentMethod: paymentMethod,
      createdAt: createdAt,
      paidAt: paidAt,
      transactionId: transactionId,
      reference: reference,
      userId: userId,
      userName: userName,
      category: category,
    );
  }
}