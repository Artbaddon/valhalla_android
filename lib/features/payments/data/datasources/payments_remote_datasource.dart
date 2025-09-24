import '../models/payment_model.dart';
import '../models/payment_method_model.dart';
import '../models/payment_stats_model.dart';

abstract class PaymentsRemoteDataSource {
  // Payment operations
  Future<List<PaymentModel>> getPayments({
    String? status,
    String? category,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<PaymentModel> getPaymentById(int id);
  
  Future<PaymentModel> createPayment({
    required String description,
    required double amount,
    required String category,
    int? paymentMethodId,
  });
  
  Future<PaymentModel> processPayment(int paymentId, int paymentMethodId);
  
  Future<PaymentModel> cancelPayment(int paymentId);
  
  Future<PaymentStatsModel> getPaymentStats();
  
  // Payment methods operations
  Future<List<PaymentMethodModel>> getPaymentMethods();
  
  Future<PaymentMethodModel> addPaymentMethod({
    required String type,
    required String name,
    required String cardNumber,
    String? expiryDate,
    String? holderName,
    String? bankName,
    bool isDefault = false,
  });
  
  Future<PaymentMethodModel> updatePaymentMethod(PaymentMethodModel paymentMethod);
  
  Future<void> deletePaymentMethod(int id);
  
  Future<PaymentMethodModel> setDefaultPaymentMethod(int id);
}