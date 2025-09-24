import '../../domain/entities/payment_stats.dart';

class PaymentStatsModel {
  final double totalAmount;
  final double monthlyAmount;
  final double weeklyAmount;
  final int totalPayments;
  final int pendingPayments;
  final int completedPayments;
  final int failedPayments;
  final Map<String, double> paymentsByCategory;
  final Map<String, int> paymentsByStatus;

  const PaymentStatsModel({
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

  factory PaymentStatsModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatsModel(
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      monthlyAmount: (json['monthlyAmount'] ?? 0.0).toDouble(),
      weeklyAmount: (json['weeklyAmount'] ?? 0.0).toDouble(),
      totalPayments: json['totalPayments'] ?? 0,
      pendingPayments: json['pendingPayments'] ?? 0,
      completedPayments: json['completedPayments'] ?? 0,
      failedPayments: json['failedPayments'] ?? 0,
      paymentsByCategory: Map<String, double>.from(json['paymentsByCategory'] ?? {}),
      paymentsByStatus: Map<String, int>.from(json['paymentsByStatus'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
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

extension PaymentStatsModelExtensions on PaymentStatsModel {
  PaymentStats toEntity() {
    return PaymentStats(
      totalAmount: totalAmount,
      monthlyAmount: monthlyAmount,
      weeklyAmount: weeklyAmount,
      totalPayments: totalPayments,
      pendingPayments: pendingPayments,
      completedPayments: completedPayments,
      failedPayments: failedPayments,
      paymentsByCategory: paymentsByCategory,
      paymentsByStatus: paymentsByStatus,
    );
  }
}