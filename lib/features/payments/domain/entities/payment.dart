class Payment {
  final int id;
  final String description;
  final double amount;
  final String status; // 'pending', 'completed', 'failed', 'cancelled'
  final String paymentMethod; // 'credit_card', 'debit_card', 'cash', 'transfer'
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? transactionId;
  final String? reference;
  final int userId;
  final String userName; 
  final String category; // 'parking', 'maintenance', 'fine', 'service'

  const Payment({
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

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] ?? 0,
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? 'credit_card',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      paidAt: map['paidAt'] != null 
          ? DateTime.parse(map['paidAt']) 
          : null,
      transactionId: map['transactionId'],
      reference: map['reference'],
      userId: map['userId'] ?? 0,
      userName: map['userName'] ?? '',
      category: map['category'] ?? 'parking',
    );
  }

  Map<String, dynamic> toMap() {
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

  Payment copyWith({
    int? id,
    String? description,
    double? amount,
    String? status,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? paidAt,
    String? transactionId,
    String? reference,
    int? userId,
    String? userName,
    String? category,
  }) {
    return Payment(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      transactionId: transactionId ?? this.transactionId,
      reference: reference ?? this.reference,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      category: category ?? this.category,
    );
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isFailed => status.toLowerCase() == 'failed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
}