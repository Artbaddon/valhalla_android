class PaymentStats {
  final double totalAmount;
  final double monthlyAmount;
  final double weeklyAmount;
  final int totalPayments;
  final int pendingPayments;
  final int completedPayments;
  final int failedPayments;
  final Map<String, double> paymentsByCategory;
  final Map<String, int> paymentsByStatus;

  const PaymentStats({
    required this.totalAmount,
    required this.monthlyAmount,
    required this.weeklyAmount,
    required this.totalPayments,
    required this.pendingPayments,
    required this.completedPayments,
    required this.failedPayments,
    required this.paymentsByCategory,
    required this.paymentsByStatus,
  });

  factory PaymentStats.fromMap(Map<String, dynamic> map) {
    return PaymentStats(
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      monthlyAmount: (map['monthlyAmount'] ?? 0.0).toDouble(),
      weeklyAmount: (map['weeklyAmount'] ?? 0.0).toDouble(),
      totalPayments: map['totalPayments'] ?? 0,
      pendingPayments: map['pendingPayments'] ?? 0,
      completedPayments: map['completedPayments'] ?? 0,
      failedPayments: map['failedPayments'] ?? 0,
      paymentsByCategory: Map<String, double>.from(map['paymentsByCategory'] ?? {}),
      paymentsByStatus: Map<String, int>.from(map['paymentsByStatus'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalAmount': totalAmount,
      'monthlyAmount': monthlyAmount,
      'weeklyAmount': weeklyAmount,
      'totalPayments': totalPayments,
      'pendingPayments': pendingPayments,
      'completedPayments': completedPayments,
      'failedPayments': failedPayments,
      'paymentsByCategory': paymentsByCategory,
      'paymentsByStatus': paymentsByStatus,
    };
  }
}