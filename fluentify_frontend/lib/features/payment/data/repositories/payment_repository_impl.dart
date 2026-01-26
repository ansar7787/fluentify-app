import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/payment_order_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_order_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final Dio dio;

  PaymentRepositoryImpl({required this.dio});

  @override
  Future<Either<Failure, PaymentOrderEntity>> createOrder({
    required double amount,
    required String description,
  }) async {
    try {
      final response = await dio.post(
        '/payments/order',
        data: {
          'amount': amount,
          'description': description,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Right(PaymentOrderModel.fromJson(response.data));
      } else {
        return const Left(ServerFailure('Failed to create order'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data['message'] ?? 'Network error occurred',
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final response = await dio.post(
        '/payments/verify',
        data: {
          'orderId': orderId,
          'paymentId': paymentId,
          'signature': signature,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Right(response.data['success'] ?? false);
      } else {
        return const Left(ServerFailure('Failed to verify payment'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data['message'] ?? 'Network error occurred',
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
