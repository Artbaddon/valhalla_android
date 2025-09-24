import '../entities/payment_method.dart';
import '../repositories/payments_repository.dart';

class ManagePaymentMethodsUseCase {
  final PaymentsRepository _repository;

  ManagePaymentMethodsUseCase(this._repository);

  Future<List<PaymentMethod>> getPaymentMethods() async {
    return await _repository.getPaymentMethods();
  }

  Future<PaymentMethod> addPaymentMethod({
    required String type,
    required String name,
    required String cardNumber,
    String? expiryDate,
    String? holderName,
    String? bankName,
    bool isDefault = false,
  }) async {
    if (type.trim().isEmpty) {
      throw ArgumentError('Payment method type cannot be empty');
    }
    
    if (name.trim().isEmpty) {
      throw ArgumentError('Payment method name cannot be empty');
    }
    
    if (cardNumber.trim().isEmpty) {
      throw ArgumentError('Card number cannot be empty');
    }

    // Basic card number validation
    final cleanCardNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanCardNumber.length < 13 || cleanCardNumber.length > 19) {
      throw ArgumentError('Invalid card number length');
    }

    return await _repository.addPaymentMethod(
      type: type.trim(),
      name: name.trim(),
      cardNumber: cardNumber.trim(),
      expiryDate: expiryDate?.trim(),
      holderName: holderName?.trim(),
      bankName: bankName?.trim(),
      isDefault: isDefault,
    );
  }

  Future<PaymentMethod> updatePaymentMethod(PaymentMethod paymentMethod) async {
    return await _repository.updatePaymentMethod(paymentMethod);
  }

  Future<void> deletePaymentMethod(int id) async {
    if (id <= 0) {
      throw ArgumentError('Payment method ID must be greater than 0');
    }
    
    return await _repository.deletePaymentMethod(id);
  }

  Future<PaymentMethod> setDefaultPaymentMethod(int id) async {
    if (id <= 0) {
      throw ArgumentError('Payment method ID must be greater than 0');
    }
    
    return await _repository.setDefaultPaymentMethod(id);
  }
}