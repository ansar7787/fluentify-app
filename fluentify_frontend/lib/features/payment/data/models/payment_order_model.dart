import '../../domain/entities/payment_order_entity.dart';

class PaymentOrderModel extends PaymentOrderEntity {
  const PaymentOrderModel({
    required super.id,
    required super.amount,
    required super.currency,
    required super.receipt,
    required super.status,
  });

  factory PaymentOrderModel.fromJson(Map<String, dynamic> json) {
    return PaymentOrderModel(
      id: json['id'] ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'INR',
      receipt: json['receipt'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'receipt': receipt,
      'status': status,
    };
  }
}
