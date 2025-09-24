class AdminStatsModel {
  final int totalUsers;
  final int totalParkingSpots;
  final int availableParkingSpots;
  final int totalVisitors;
  final int activeVisitors;
  final int totalReservations;
  final int totalPackages;
  final double totalRevenue;

  const AdminStatsModel({
    required this.totalUsers,
    required this.totalParkingSpots,
    required this.availableParkingSpots,
    required this.totalVisitors,
    required this.activeVisitors,
    required this.totalReservations,
    required this.totalPackages,
    required this.totalRevenue,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUsers: json['totalUsers'] ?? 0,
      totalParkingSpots: json['totalParkingSpots'] ?? 0,
      availableParkingSpots: json['availableParkingSpots'] ?? 0,
      totalVisitors: json['totalVisitors'] ?? 0,
      activeVisitors: json['activeVisitors'] ?? 0,
      totalReservations: json['totalReservations'] ?? 0,
      totalPackages: json['totalPackages'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
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