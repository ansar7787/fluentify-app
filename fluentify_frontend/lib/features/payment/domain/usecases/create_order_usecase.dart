import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_order_entity.dart';
import '../repositories/payment_repository.dart';

class CreateOrderUseCase
    implements UseCase<PaymentOrderEntity, CreateOrderParams> {
  final PaymentRepository repository;

  CreateOrderUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentOrderEntity>> call(
      CreateOrderParams params) async {
    return await repository.createOrder(
      amount: params.amount,
      description: params.description,
    );
  }
}

class CreateOrderParams {
  final double amount;
  final String description;

  CreateOrderParams({required this.amount, required this.description});
}
