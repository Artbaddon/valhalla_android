import 'package:flutter/material.dart';
import '../../domain/entities/admin_stats.dart';
import '../../domain/entities/parking_spot.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/usecases/get_admin_stats_usecase.dart';
import '../../domain/usecases/manage_parking_spots_usecase.dart';
import '../../domain/usecases/manage_visitors_usecase.dart';

/// View model for admin dashboard functionality
class AdminViewModel extends ChangeNotifier {
  final GetAdminStatsUseCase _getAdminStatsUseCase;
  final ManageParkingSpotsUseCase _manageParkingSpotsUseCase;
  final ManageVisitorsUseCase _manageVisitorsUseCase;

  AdminViewModel(
    this._getAdminStatsUseCase,
    this._manageParkingSpotsUseCase,
    this._manageVisitorsUseCase,
  );

  // State variables
  AdminStats? _adminStats;
  List<ParkingSpot> _parkingSpots = [];
  List<Visitor> _visitors = [];
  bool _isLoading = false;
  bool _isParkingLoading = false;
  bool _isVisitorsLoading = false;
  String? _errorMessage;
  
  // Filters
  String? _parkingTypeFilter;
  String? _parkingStatusFilter;
  String _parkingSearchQuery = '';
  String? _visitorStatusFilter;
  String _visitorSearchQuery = '';

  // Getters
  AdminStats? get adminStats => _adminStats;
  List<ParkingSpot> get parkingSpots => _parkingSpots;
  List<Visitor> get visitors => _visitors;
  bool get isLoading => _isLoading;
  bool get isParkingLoading => _isParkingLoading;
  bool get isVisitorsLoading => _isVisitorsLoading;
  String? get errorMessage => _errorMessage;
  String? get parkingTypeFilter => _parkingTypeFilter;
  String? get parkingStatusFilter => _parkingStatusFilter;
  String get parkingSearchQuery => _parkingSearchQuery;
  String? get visitorStatusFilter => _visitorStatusFilter;
  String get visitorSearchQuery => _visitorSearchQuery;

  // Filtered lists
  List<ParkingSpot> get filteredParkingSpots {
    var filtered = _parkingSpots;
    
    // Apply status filter
    if (_parkingStatusFilter != null && _parkingStatusFilter!.isNotEmpty) {
      filtered = filtered.where((spot) => 
        spot.status.toLowerCase() == _parkingStatusFilter!.toLowerCase()
      ).toList();
    }
    
    // Apply search query
    if (_parkingSearchQuery.isNotEmpty) {
      final query = _parkingSearchQuery.toLowerCase();
      filtered = filtered.where((spot) =>
        spot.number.toLowerCase().contains(query) ||
        (spot.ownerName?.toLowerCase().contains(query) ?? false) ||
        (spot.vehiclePlate?.toLowerCase().contains(query) ?? false)
      ).toList();
    }
    
    return filtered;
  }

  List<Visitor> get filteredVisitors {
    var filtered = _visitors;
    
    // Apply status filter
    if (_visitorStatusFilter != null && _visitorStatusFilter!.isNotEmpty) {
      filtered = filtered.where((visitor) => 
        visitor.status.toLowerCase() == _visitorStatusFilter!.toLowerCase()
      ).toList();
    }
    
    // Apply search query
    if (_visitorSearchQuery.isNotEmpty) {
      final query = _visitorSearchQuery.toLowerCase();
      filtered = filtered.where((visitor) =>
        visitor.name.toLowerCase().contains(query) ||
        visitor.documentNumber.toLowerCase().contains(query) ||
        visitor.hostName.toLowerCase().contains(query)
      ).toList();
    }
    
    return filtered;
  }

  /// Loads admin dashboard statistics
  Future<void> loadAdminStats() async {
    _setLoading(true);
    _clearError();

    try {
      _adminStats = await _getAdminStatsUseCase.call();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Loads parking spots with current filters
  Future<void> loadParkingSpots() async {
    _isParkingLoading = true;
    _clearError();
    notifyListeners();

    try {
      _parkingSpots = await _manageParkingSpotsUseCase.getParkingSpots(
        typeFilter: _parkingTypeFilter,
        statusFilter: _parkingStatusFilter,
        searchQuery: _parkingSearchQuery.isNotEmpty ? _parkingSearchQuery : null,
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _isParkingLoading = false;
      notifyListeners();
    }
  }

  /// Updates parking spot filters
  void setParkingFilters({
    String? typeFilter,
    String? statusFilter,
    String? searchQuery,
  }) {
    bool hasChanged = false;
    
    if (typeFilter != _parkingTypeFilter) {
      _parkingTypeFilter = typeFilter;
      hasChanged = true;
    }
    
    if (statusFilter != _parkingStatusFilter) {
      _parkingStatusFilter = statusFilter;
      hasChanged = true;
    }
    
    if (searchQuery != null && searchQuery != _parkingSearchQuery) {
      _parkingSearchQuery = searchQuery;
      hasChanged = true;
    }

    if (hasChanged) {
      notifyListeners();
      loadParkingSpots();
    }
  }

  /// Updates parking spot filter (simplified version for widgets)
  void setParkingFilter({String? searchTerm, String? status}) {
    setParkingFilters(
      searchQuery: searchTerm,
      statusFilter: status,
    );
  }

  /// Updates parking spot status
  Future<bool> updateParkingSpotStatus(int spotId, String status) async {
    try {
      final spot = _parkingSpots.firstWhere((s) => s.id == spotId);
      final updatedSpot = ParkingSpot(
        id: spot.id,
        number: spot.number,
        type: spot.type,
        status: status,
        ownerName: spot.ownerName,
        vehiclePlate: spot.vehiclePlate,
      );
      
      await _manageParkingSpotsUseCase.updateParkingSpot(updatedSpot);
      
      // Update local list
      final index = _parkingSpots.indexWhere((s) => s.id == spotId);
      if (index != -1) {
        _parkingSpots[index] = updatedSpot;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Updates a parking spot
  Future<bool> updateParkingSpot(ParkingSpot parkingSpot) async {
    try {
      await _manageParkingSpotsUseCase.updateParkingSpot(parkingSpot);
      
      // Update local list
      final index = _parkingSpots.indexWhere((spot) => spot.id == parkingSpot.id);
      if (index != -1) {
        _parkingSpots[index] = parkingSpot;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Loads visitors with current filters
  Future<void> loadVisitors() async {
    _isVisitorsLoading = true;
    _clearError();
    notifyListeners();

    try {
      _visitors = await _manageVisitorsUseCase.getVisitors(
        statusFilter: _visitorStatusFilter,
        searchQuery: _visitorSearchQuery.isNotEmpty ? _visitorSearchQuery : null,
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _isVisitorsLoading = false;
      notifyListeners();
    }
  }

  /// Updates visitor filters
  void setVisitorFilters({
    String? statusFilter,
    String? searchQuery,
  }) {
    bool hasChanged = false;
    
    if (statusFilter != _visitorStatusFilter) {
      _visitorStatusFilter = statusFilter;
      hasChanged = true;
    }
    
    if (searchQuery != null && searchQuery != _visitorSearchQuery) {
      _visitorSearchQuery = searchQuery;
      hasChanged = true;
    }

    if (hasChanged) {
      notifyListeners();
      loadVisitors();
    }
  }

  /// Updates visitor status
  Future<bool> updateVisitorStatus(int visitorId, String status) async {
    try {
      await _manageVisitorsUseCase.updateVisitorStatus(visitorId, status);
      
      // Update local list
      final index = _visitors.indexWhere((visitor) => visitor.id == visitorId);
      if (index != -1) {
        _visitors[index] = _visitors[index].copyWith(status: status);
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Gets visitor by ID
  Future<Visitor?> getVisitorById(int id) async {
    try {
      return await _manageVisitorsUseCase.getVisitorById(id);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Creates a new visitor
  Future<Visitor?> createVisitor({
    required String name,
    required String documentNumber,
    required String hostName,
    int? hostId,
    String? vehiclePlate,
    String? phoneNumber,
  }) async {
    try {
      final visitor = await _manageVisitorsUseCase.createVisitor(
        name: name,
        documentNumber: documentNumber,
        hostName: hostName,
        hostId: hostId,
        vehiclePlate: vehiclePlate,
        phoneNumber: phoneNumber,
      );
      
      // Add to local list
      _visitors.insert(0, visitor);
      notifyListeners();
      
      return visitor;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Clears any error messages
  void clearError() {
    _clearError();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}