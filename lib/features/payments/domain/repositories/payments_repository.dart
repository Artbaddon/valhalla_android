import '../entities/payment.dart';
import '../entities/payment_method.dart';
import '../entities/payment_stats.dart';

abstract class PaymentsRepository {
  // Payment operations
  Future<List<Payment>> getPayments({
    String? status,
    String? category,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<Payment> getPaymentById(int id);
  
  Future<Payment> createPayment({
    required String description,
    required double amount,
    required String category,
    int? paymentMethodId,
  });
  
  Future<Payment> processPayment(int paymentId, int paymentMethodId);
  
  Future<Payment> cancelPayment(int paymentId);
  
  Future<PaymentStats> getPaymentStats();
  
  // Payment methods operations
  Future<List<PaymentMethod>> getPaymentMethods();
  
  Future<PaymentMethod> addPaymentMethod({
    required String type,
    required String name,
    required String cardNumber,
    String? expiryDate,
    String? holderName,
    String? bankName,
    bool isDefault = false,
  });
  
  Future<PaymentMethod> updatePaymentMethod(PaymentMethod paymentMethod);
  
  Future<void> deletePaymentMethod(int id);
  
  Future<PaymentMethod> setDefaultPaymentMethod(int id);
}