class OwnerStatsModel {
  final int totalReservations;
  final int activeReservations;
  final double totalPayments;
  final int pendingPayments;

  const OwnerStatsModel({
    required this.totalReservations,
    required this.activeReservations,
    required this.totalPayments,
    required this.pendingPayments,
  });

  factory OwnerStatsModel.fromJson(Map<String, dynamic> json) {
    return OwnerStatsModel(
      totalReservations: json['totalReservations'] ?? 0,
      activeReservations: json['activeReservations'] ?? 0,
      totalPayments: (json['totalPayments'] ?? 0.0).toDouble(),
      pendingPayments: json['pendingPayments'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReservations': totalReservations,
      'activeReservations': activeReservations,
      'totalPayments': totalPayments,
      'pendingPayments': pendingPayments,
    };
  }
}