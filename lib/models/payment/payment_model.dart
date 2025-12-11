// Payment model parsed from backend keys
class Payment {
  final int id; // payment_id
  final int? ownerIdFk; // Owner_ID_FK
  final double amount; // amount (cambié de totalPayment a amount)
  final int? statusIdFk; // Payment_Status_ID_FK
  final DateTime? date; // Payment_date
  final String method; // Payment_method
  final String referenceNumber; // Payment_reference_number
  final String statusName; // Payment_status_name
  final int? ownerId; // Owner_id
  final String ownerName; // owner_name
  final String currency; // currency

  const Payment({
    required this.id,
    required this.ownerIdFk,
    required this.amount,
    required this.statusIdFk,
    required this.date,
    required this.method,
    required this.referenceNumber,
    required this.statusName,
    required this.ownerId,
    required this.ownerName,
    required this.currency,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, {int defaultValue = 0}) {
      if (v == null) return defaultValue;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? defaultValue;
    }

    int? toIntOrNull(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    double toDouble(dynamic v, {double defaultValue = 0.0}) {
      if (v == null) return defaultValue;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? defaultValue;
    }

    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    String toStr(dynamic v) => v?.toString() ?? '';

    return Payment(
      id: toInt(json['payment_id'] ?? json['Payment_id'], defaultValue: 0),
      ownerIdFk: toIntOrNull(json['Owner_ID_FK'] ?? json['owner_id_fk']),
      amount: toDouble(
        json['amount'] ?? json['Amount'],
        defaultValue: 0.0,
      ), // ✅ Cambiado a amount
      statusIdFk: toIntOrNull(
        json['Payment_Status_ID_FK'] ?? json['status_id_fk'],
      ),
      date: toDate(json['Payment_date'] ?? json['payment_date']),
      method: toStr(json['Payment_method'] ?? json['method']),
      referenceNumber: toStr(
        json['Payment_reference_number'] ?? json['reference_number'],
      ),
      statusName: toStr(json['Payment_status_name'] ?? json['status_name']),
      ownerId: toIntOrNull(json['Owner_id'] ?? json['owner_id']),
      ownerName: toStr(json['owner_name'] ?? json['Owner_name']),
      currency: toStr(
        json['currency'] ?? json['Currency'] ?? 'COP',
      ), // ✅ Agregado currency
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': id,
      'Owner_ID_FK': ownerIdFk,
      'amount': amount,
      'Payment_Status_ID_FK': statusIdFk,
      'Payment_date': date?.toIso8601String(),
      'Payment_method': method,
      'Payment_reference_number': referenceNumber,
      'Payment_status_name': statusName,
      'Owner_id': ownerId,
      'owner_name': ownerName,
      'currency': currency,
    };
  }

  // Optional: Para compatibilidad con código existente
  int get totalPayment => amount.round();
}