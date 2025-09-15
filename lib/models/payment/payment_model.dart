// Payment models
class Payment {
  final String id;
  final String userId;
  final double amount;
  final PaymentStatus status;
  final PaymentMethod method;
  final DateTime createdAt;
  final DateTime? completedAt;

  Payment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.status,
    required this.method,
    required this.createdAt,
    this.completedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['user_id'],
      amount: json['amount'].toDouble(),
      status: PaymentStatus.values.firstWhere((e) => e.name == json['status']),
      method: PaymentMethod.fromJson(json['method']),
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
    );
  }
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

class PaymentMethod {
  final String id;
  final String type; // 'card', 'bank', 'digital_wallet'
  final String lastFour;
  final String? brand;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.lastFour,
    this.brand,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      lastFour: json['last_four'],
      brand: json['brand'],
    );
  }
}