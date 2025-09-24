class OwnerStats {
  final int totalReservations;
  final int activeReservations;
  final double totalPayments;
  final int pendingPayments;

  const OwnerStats({
    required this.totalReservations,
    required this.activeReservations,
    required this.totalPayments,
    required this.pendingPayments,
  });

  factory OwnerStats.fromMap(Map<String, dynamic> map) {
    return OwnerStats(
      totalReservations: map['totalReservations'] ?? 0,
      activeReservations: map['activeReservations'] ?? 0,
      totalPayments: (map['totalPayments'] ?? 0.0).toDouble(),
      pendingPayments: map['pendingPayments'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalReservations': totalReservations,
      'activeReservations': activeReservations,
      'totalPayments': totalPayments,
      'pendingPayments': pendingPayments,
    };
  }
}