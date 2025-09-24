import '../../../../core/network/dio_client.dart';
import '../models/payment_model.dart';
import '../models/payment_method_model.dart';
import '../models/payment_stats_model.dart';
import 'payments_remote_datasource.dart';

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  final DioClient _dioClient;

  PaymentsRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<PaymentModel>> getPayments({
    String? status,
    String? category,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    
    if (status != null) queryParams['status'] = status;
    if (category != null) queryParams['category'] = category;
    if (searchQuery != null) queryParams['search'] = searchQuery;
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

    final response = await _dioClient.get(
      '/payments',
      queryParameters: queryParams,
    );

    final List<dynamic> paymentsJson = response.data['data'] ?? [];
    return paymentsJson.map((json) => PaymentModel.fromJson(json)).toList();
  }

  @override
  Future<PaymentModel> getPaymentById(int id) async {
    final response = await _dioClient.get('/payments/$id');
    return PaymentModel.fromJson(response.data['data']);
  }

  @override
  Future<PaymentModel> createPayment({
    required String description,
    required double amount,
    required String category,
    int? paymentMethodId,
  }) async {
    final response = await _dioClient.post(
      '/payments',
      data: {
        'description': description,
        'amount': amount,
        'category': category,
        if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      },
    );

    return PaymentModel.fromJson(response.data['data']);
  }

  @override
  Future<PaymentModel> processPayment(int paymentId, int paymentMethodId) async {
    final response = await _dioClient.post(
      '/payments/$paymentId/process',
      data: {
        'payment_method_id': paymentMethodId,
      },
    );

    return PaymentModel.fromJson(response.data['data']);
  }

  @override
  Future<PaymentModel> cancelPayment(int paymentId) async {
    final response = await _dioClient.post(
      '/payments/$paymentId/cancel',
    );

    return PaymentModel.fromJson(response.data['data']);
  }

  @override
  Future<PaymentStatsModel> getPaymentStats() async {
    final response = await _dioClient.get('/payments/stats');
    return PaymentStatsModel.fromJson(response.data['data']);
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final response = await _dioClient.get('/payment-methods');
    
    final List<dynamic> methodsJson = response.data['data'] ?? [];
    return methodsJson.map((json) => PaymentMethodModel.fromJson(json)).toList();
  }

  @override
  Future<PaymentMethodModel> addPaymentMethod({
    required String type,
    required String name,
    required String cardNumber,
    String? expiryDate,
    String? holderName,
    String? bankName,
    bool isDefault = false,
  }) async {
    final response = await _dioClient.post(
      '/payment-methods',
      data: {
        'type': type,
        'name': name,
        'card_number': cardNumber,
        if (expiryDate != null) 'expiry_date': expiryDate,
        if (holderName != null) 'holder_name': holderName,
        if (bankName != null) 'bank_name': bankName,
        'is_default': isDefault,
      },
    );

    return PaymentMethodModel.fromJson(response.data['data']);
  }

  @override
  Future<PaymentMethodModel> updatePaymentMethod(PaymentMethodModel paymentMethod) async {
    final response = await _dioClient.post(
      '/payment-methods/${paymentMethod.id}/update',
      data: paymentMethod.toJson(),
    );

    return PaymentMethodModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deletePaymentMethod(int id) async {
    await _dioClient.post('/payment-methods/$id/delete');
  }

  @override
  Future<PaymentMethodModel> setDefaultPaymentMethod(int id) async {
    final response = await _dioClient.post(
      '/payment-methods/$id/set-default',
    );

    return PaymentMethodModel.fromJson(response.data['data']);
  }
}