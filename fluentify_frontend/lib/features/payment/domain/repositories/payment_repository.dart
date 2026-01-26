import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_order_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentOrderEntity>> createOrder({
    required double amount,
    required String description,
  });

  Future<Either<Failure, bool>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  });
}
