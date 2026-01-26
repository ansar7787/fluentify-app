import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_order_entity.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentOrderCreated extends PaymentState {
  final PaymentOrderEntity order;

  const PaymentOrderCreated(this.order);

  @override
  List<Object?> get props => [order];
}

class PaymentSuccess extends PaymentState {
  final String message;

  const PaymentSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentFailure extends PaymentState {
  final String message;

  const PaymentFailure(this.message);

  @override
  List<Object?> get props => [message];
}
