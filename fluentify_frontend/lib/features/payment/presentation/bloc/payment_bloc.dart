import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/verify_payment_usecase.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreateOrderUseCase createOrderUseCase;
  final VerifyPaymentUseCase verifyPaymentUseCase;

  PaymentBloc({
    required this.createOrderUseCase,
    required this.verifyPaymentUseCase,
  }) : super(PaymentInitial()) {
    on<CreatePaymentOrderEvent>((event, emit) async {
      emit(PaymentLoading());

      final result = await createOrderUseCase(
        CreateOrderParams(
          amount: event.amount,
          description: event.description,
        ),
      );

      result.fold(
        (failure) => emit(PaymentFailure(failure.message)),
        (order) => emit(PaymentOrderCreated(order)),
      );
    });

    on<VerifyPaymentEvent>((event, emit) async {
      emit(PaymentLoading());

      final result = await verifyPaymentUseCase(
        VerifyPaymentParams(
          orderId: event.orderId,
          paymentId: event.paymentId,
          signature: event.signature,
        ),
      );

      result.fold(
        (failure) => emit(PaymentFailure(failure.message)),
        (success) {
          if (success) {
            emit(const PaymentSuccess('Payment successful and verified!'));
          } else {
            emit(const PaymentFailure('Payment verification failed'));
          }
        },
      );
    });
  }
}
