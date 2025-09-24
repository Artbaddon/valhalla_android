import '../entities/payment.dart';
import '../entities/payment_stats.dart';
import '../repositories/payments_repository.dart';

class GetPaymentsUseCase {
  final PaymentsRepository _repository;

  GetPaymentsUseCase(this._repository);

  Future<List<Payment>> call({
    String? status,
    String? category,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getPayments(
      status: status,
      category: category,
      searchQuery: searchQuery,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class GetPaymentStatsUseCase {
  final PaymentsRepository _repository;

  GetPaymentStatsUseCase(this._repository);

  Future<PaymentStats> call() async {
    return await _repository.getPaymentStats();
  }
}

class ProcessPaymentUseCase {
  final PaymentsRepository _repository;

  ProcessPaymentUseCase(this._repository);

  Future<Payment> call(int paymentId, int paymentMethodId) async {
    if (paymentId <= 0) {
      throw ArgumentError('Payment ID must be greater than 0');
    }
    
    if (paymentMethodId <= 0) {
      throw ArgumentError('Payment method ID must be greater than 0');
    }

    return await _repository.processPayment(paymentId, paymentMethodId);
  }
}

class CreatePaymentUseCase {
  final PaymentsRepository _repository;

  CreatePaymentUseCase(this._repository);

  Future<Payment> call({
    required String description,
    required double amount,
    required String category,
    int? paymentMethodId,
  }) async {
    if (description.trim().isEmpty) {
      throw ArgumentError('Description cannot be empty');
    }
    
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than 0');
    }
    
    if (category.trim().isEmpty) {
      throw ArgumentError('Category cannot be empty');
    }

    return await _repository.createPayment(
      description: description.trim(),
      amount: amount,
      category: category.trim(),
      paymentMethodId: paymentMethodId,
    );
  }
}