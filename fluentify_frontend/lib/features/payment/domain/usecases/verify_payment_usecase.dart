import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/payment_repository.dart';

class VerifyPaymentUseCase implements UseCase<bool, VerifyPaymentParams> {
  final PaymentRepository repository;

  VerifyPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(VerifyPaymentParams params) async {
    return await repository.verifyPayment(
      orderId: params.orderId,
      paymentId: params.paymentId,
      signature: params.signature,
    );
  }
}

class VerifyPaymentParams {
  final String orderId;
  final String paymentId;
  final String signature;

  VerifyPaymentParams({
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });
}
