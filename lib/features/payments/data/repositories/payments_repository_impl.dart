import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_stats.dart';
import '../../domain/repositories/payments_repository.dart';
import '../datasources/payments_remote_datasource.dart';
import '../models/payment_model.dart';
import '../models/payment_method_model.dart';
import '../models/payment_stats_model.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource _remoteDataSource;

  PaymentsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Payment>> getPayments({
    String? status,
    String? category,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final models = await _remoteDataSource.getPayments(
      status: status,
      category: category,
      searchQuery: searchQuery,
      startDate: startDate,
      endDate: endDate,
    );
    
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Payment> getPaymentById(int id) async {
    final model = await _remoteDataSource.getPaymentById(id);
    return model.toEntity();
  }

  @override
  Future<Payment> createPayment({
    required String description,
    required double amount,
    required String category,
    int? paymentMethodId,
  }) async {
    final model = await _remoteDataSource.createPayment(
      description: description,
      amount: amount,
      category: category,
      paymentMethodId: paymentMethodId,
    );
    
    return model.toEntity();
  }

  @override
  Future<Payment> processPayment(int paymentId, int paymentMethodId) async {
    final model = await _remoteDataSource.processPayment(paymentId, paymentMethodId);
    return model.toEntity();
  }

  @override
  Future<Payment> cancelPayment(int paymentId) async {
    final model = await _remoteDataSource.cancelPayment(paymentId);
    return model.toEntity();
  }

  @override
  Future<PaymentStats> getPaymentStats() async {
    final model = await _remoteDataSource.getPaymentStats();
    return model.toEntity();
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods() async {
    final models = await _remoteDataSource.getPaymentMethods();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<PaymentMethod> addPaymentMethod({
    required String type,
    required String name,
    required String cardNumber,
    String? expiryDate,
    String? holderName,
    String? bankName,
    bool isDefault = false,
  }) async {
    final model = await _remoteDataSource.addPaymentMethod(
      type: type,
      name: name,
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      holderName: holderName,
      bankName: bankName,
      isDefault: isDefault,
    );
    
    return model.toEntity();
  }

  @override
  Future<PaymentMethod> updatePaymentMethod(PaymentMethod paymentMethod) async {
    final model = await _remoteDataSource.updatePaymentMethod(paymentMethod.toModel());
    return model.toEntity();
  }

  @override
  Future<void> deletePaymentMethod(int id) async {
    await _remoteDataSource.deletePaymentMethod(id);
  }

  @override
  Future<PaymentMethod> setDefaultPaymentMethod(int id) async {
    final model = await _remoteDataSource.setDefaultPaymentMethod(id);
    return model.toEntity();
  }
}