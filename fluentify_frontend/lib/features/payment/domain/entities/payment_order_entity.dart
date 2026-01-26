import 'package:equatable/equatable.dart';

class PaymentOrderEntity extends Equatable {
  final String id;
  final int amount;
  final String currency;
  final String receipt;
  final String status;
  final Map<String, dynamic>? notes;

  const PaymentOrderEntity({
    required this.id,
    required this.amount,
    required this.currency,
    required this.receipt,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [id, amount, currency, receipt, status, notes];
}
