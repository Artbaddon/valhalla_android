import 'package:flutter/material.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_stats.dart';
import '../../domain/usecases/get_payments_usecase.dart';
import '../../domain/usecases/manage_payment_methods_usecase.dart';

/// View model for payments functionality
class PaymentsViewModel extends ChangeNotifier {
  final GetPaymentsUseCase _getPaymentsUseCase;
  final GetPaymentStatsUseCase _getPaymentStatsUseCase;
  final ProcessPaymentUseCase _processPaymentUseCase;
  final CreatePaymentUseCase _createPaymentUseCase;
  final ManagePaymentMethodsUseCase _managePaymentMethodsUseCase;

  PaymentsViewModel(
    this._getPaymentsUseCase,
    this._getPaymentStatsUseCase,
    this._processPaymentUseCase,
    this._createPaymentUseCase,
    this._managePaymentMethodsUseCase,
  );

  // State variables
  List<Payment> _payments = [];
  List<PaymentMethod> _paymentMethods = [];
  PaymentStats? _paymentStats;
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _errorMessage;
  
  // Filters
  String? _statusFilter;
  String? _categoryFilter;
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters
  List<Payment> get payments => _payments;
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  PaymentStats? get paymentStats => _paymentStats;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  String? get statusFilter => _statusFilter;
  String? get categoryFilter => _categoryFilter;
  String get searchQuery => _searchQuery;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Filtered lists
  List<Payment> get filteredPayments {
    var filtered = _payments;
    
    // Apply status filter
    if (_statusFilter != null && _statusFilter!.isNotEmpty) {
      filtered = filtered.where((payment) => 
        payment.status.toLowerCase() == _statusFilter!.toLowerCase()
      ).toList();
    }
    
    // Apply category filter
    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      filtered = filtered.where((payment) => 
        payment.category.toLowerCase() == _categoryFilter!.toLowerCase()
      ).toList();
    }
    
    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((payment) =>
        payment.description.toLowerCase().contains(query) ||
        payment.userName.toLowerCase().contains(query) ||
        payment.reference?.toLowerCase().contains(query) == true
      ).toList();
    }
    
    // Apply date filters
    if (_startDate != null) {
      filtered = filtered.where((payment) =>
        payment.createdAt.isAfter(_startDate!) || 
        payment.createdAt.isAtSameMomentAs(_startDate!)
      ).toList();
    }
    
    if (_endDate != null) {
      filtered = filtered.where((payment) =>
        payment.createdAt.isBefore(_endDate!) || 
        payment.createdAt.isAtSameMomentAs(_endDate!)
      ).toList();
    }
    
    return filtered;
  }

  List<PaymentMethod> get activePaymentMethods {
    return _paymentMethods.where((method) => method.isActive).toList();
  }

  PaymentMethod? get defaultPaymentMethod {
    try {
      return _paymentMethods.firstWhere((method) => method.isDefault && method.isActive);
    } catch (e) {
      return null;
    }
  }

  /// Loads payments with current filters
  Future<void> loadPayments() async {
    _setLoading(true);
    _clearError();

    try {
      _payments = await _getPaymentsUseCase(
        status: _statusFilter,
        category: _categoryFilter,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        startDate: _startDate,
        endDate: _endDate,
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Loads payment statistics
  Future<void> loadPaymentStats() async {
    _setLoading(true);
    _clearError();

    try {
      _paymentStats = await _getPaymentStatsUseCase();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Loads payment methods
  Future<void> loadPaymentMethods() async {
    try {
      _paymentMethods = await _managePaymentMethodsUseCase.getPaymentMethods();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Updates payment filters
  void setPaymentFilters({
    String? status,
    String? category,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    bool hasChanged = false;
    
    if (status != _statusFilter) {
      _statusFilter = status;
      hasChanged = true;
    }
    
    if (category != _categoryFilter) {
      _categoryFilter = category;
      hasChanged = true;
    }
    
    if (searchQuery != null && searchQuery != _searchQuery) {
      _searchQuery = searchQuery;
      hasChanged = true;
    }
    
    if (startDate != _startDate) {
      _startDate = startDate;
      hasChanged = true;
    }
    
    if (endDate != _endDate) {
      _endDate = endDate;
      hasChanged = true;
    }

    if (hasChanged) {
      notifyListeners();
      loadPayments();
    }
  }

  /// Processes a payment
  Future<bool> processPayment(int paymentId, int paymentMethodId) async {
    _setProcessing(true);

    try {
      final updatedPayment = await _processPaymentUseCase(paymentId, paymentMethodId);
      
      // Update local list
      final index = _payments.indexWhere((payment) => payment.id == paymentId);
      if (index != -1) {
        _payments[index] = updatedPayment;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setProcessing(false);
    }
  }

  /// Creates a new payment
  Future<Payment?> createPayment({
    required String description,
    required double amount,
    required String category,
    int? paymentMethodId,
  }) async {
    try {
      final payment = await _createPaymentUseCase(
        description: description,
        amount: amount,
        category: category,
        paymentMethodId: paymentMethodId,
      );
      
      // Add to local list
      _payments.insert(0, payment);
      notifyListeners();
      
      return payment;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Adds a new payment method
  Future<PaymentMethod?> addPaymentMethod({
    required String type,
    required String name,
    required String cardNumber,
    String? expiryDate,
    String? holderName,
    String? bankName,
    bool isDefault = false,
  }) async {
    try {
      final paymentMethod = await _managePaymentMethodsUseCase.addPaymentMethod(
        type: type,
        name: name,
        cardNumber: cardNumber,
        expiryDate: expiryDate,
        holderName: holderName,
        bankName: bankName,
        isDefault: isDefault,
      );
      
      // Update local list
      _paymentMethods.add(paymentMethod);
      notifyListeners();
      
      return paymentMethod;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Deletes a payment method
  Future<bool> deletePaymentMethod(int id) async {
    try {
      await _managePaymentMethodsUseCase.deletePaymentMethod(id);
      
      // Remove from local list
      _paymentMethods.removeWhere((method) => method.id == id);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Sets default payment method
  Future<bool> setDefaultPaymentMethod(int id) async {
    try {
      final updatedMethod = await _managePaymentMethodsUseCase.setDefaultPaymentMethod(id);
      
      // Update local list - set all to non-default first
      for (int i = 0; i < _paymentMethods.length; i++) {
        _paymentMethods[i] = _paymentMethods[i].copyWith(isDefault: false);
      }
      
      // Set the selected one as default
      final index = _paymentMethods.indexWhere((method) => method.id == id);
      if (index != -1) {
        _paymentMethods[index] = updatedMethod;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Clears any error messages
  void clearError() {
    _clearError();
  }

  /// Clears all filters
  void clearFilters() {
    _statusFilter = null;
    _categoryFilter = null;
    _searchQuery = '';
    _startDate = null;
    _endDate = null;
    notifyListeners();
    loadPayments();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setProcessing(bool processing) {
    _isProcessing = processing;
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