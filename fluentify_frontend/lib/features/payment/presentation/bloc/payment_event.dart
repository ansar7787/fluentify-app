import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class CreatePaymentOrderEvent extends PaymentEvent {
  final double amount;
  final String description;

  const CreatePaymentOrderEvent({
    required this.amount,
    required this.description,
  });

  @override
  List<Object?> get props => [amount, description];
}

class VerifyPaymentEvent extends PaymentEvent {
  final String orderId;
  final String paymentId;
  final String signature;

  const VerifyPaymentEvent({
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });

  @override
  List<Object?> get props => [orderId, paymentId, signature];
}
