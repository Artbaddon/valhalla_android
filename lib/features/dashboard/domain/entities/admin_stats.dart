class AdminStats {
  final int totalUsers;
  final int totalParkingSpots;
  final int availableParkingSpots;
  final int totalVisitors;
  final int activeVisitors;
  final int totalReservations;
  final int totalPackages;
  final double totalRevenue;

  const AdminStats({
    required this.totalUsers,
    required this.totalParkingSpots,
    required this.availableParkingSpots,
    required this.totalVisitors,
    required this.activeVisitors,
    required this.totalReservations,
    required this.totalPackages,
    required this.totalRevenue,
  });

  factory AdminStats.fromMap(Map<String, dynamic> map) {
    return AdminStats(
      totalUsers: map['totalUsers'] ?? 0,
      totalParkingSpots: map['totalParkingSpots'] ?? 0,
      availableParkingSpots: map['availableParkingSpots'] ?? 0,
      totalVisitors: map['totalVisitors'] ?? 0,
      activeVisitors: map['activeVisitors'] ?? 0,
      totalReservations: map['totalReservations'] ?? 0,
      totalPackages: map['totalPackages'] ?? 0,
      totalRevenue: (map['totalRevenue'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalUsers': totalUsers,
      'totalParkingSpots': totalParkingSpots,
      'availableParkingSpots': availableParkingSpots,
      'totalVisitors': totalVisitors,
      'activeVisitors': activeVisitors,
      'totalReservations': totalReservations,
      'totalPackages': totalPackages,
      'totalRevenue': totalRevenue,
    };
  }
}