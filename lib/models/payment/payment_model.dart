// Payment model parsed from backend keys
class Payment {
  final int id; // payment_id
  final int? ownerIdFk; // Owner_ID_FK
  final int totalPayment; // Payment_total_payment
  final int? statusIdFk; // Payment_Status_ID_FK
  final DateTime? date; // Payment_date
  final String method; // Payment_method
  final String referenceNumber; // Payment_reference_number
  final String statusName; // Payment_status_name
  final int? ownerId; // Owner_id
  final String ownerName; // owner_name

  const Payment({
    required this.id,
    required this.ownerIdFk,
    required this.totalPayment,
    required this.statusIdFk,
    required this.date,
    required this.method,
    required this.referenceNumber,
    required this.statusName,
    required this.ownerId,
    required this.ownerName,
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

    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    String toStr(dynamic v) => v?.toString() ?? '';

    return Payment(
      id: toInt(json['payment_id'] ?? json['Payment_id'], defaultValue: 0),
      ownerIdFk: toIntOrNull(json['Owner_ID_FK'] ?? json['owner_id_fk']),
      totalPayment: toInt(json['Payment_total_payment'] ?? json['total_payment'], defaultValue: 0),
      statusIdFk: toIntOrNull(json['Payment_Status_ID_FK'] ?? json['status_id_fk']),
      date: toDate(json['Payment_date'] ?? json['payment_date']),
      method: toStr(json['Payment_method'] ?? json['method']),
      referenceNumber: toStr(json['Payment_reference_number'] ?? json['reference_number']),
      statusName: toStr(json['Payment_status_name'] ?? json['status_name']),
      ownerId: toIntOrNull(json['Owner_id'] ?? json['owner_id']),
      ownerName: toStr(json['owner_name'] ?? json['Owner_name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': id,
      'Owner_ID_FK': ownerIdFk,
      'Payment_total_payment': totalPayment,
      'Payment_Status_ID_FK': statusIdFk,
      'Payment_date': date?.toIso8601String(),
      'Payment_method': method,
      'Payment_reference_number': referenceNumber,
      'Payment_status_name': statusName,
      'Owner_id': ownerId,
      'owner_name': ownerName,
    };
  }
}