import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final Dio dio;

  UserRepositoryImpl({required this.dio});

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final response = await dio.get('/users/me');

      if (response.statusCode == 200) {
        return Right(UserModel.fromJson(response.data));
      } else {
        return const Left(ServerFailure('Failed to fetch profile'));
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
  Future<Either<Failure, List<UserEntity>>> getLeaderboard(
      {int limit = 20}) async {
    try {
      final response = await dio
          .get('/users/leaderboard', queryParameters: {'limit': limit});

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return Right(data.map((json) => UserModel.fromJson(json)).toList());
      } else {
        return const Left(ServerFailure('Failed to fetch leaderboard'));
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
  Future<Either<Failure, UserEntity>> updateProfile(
      {String? fullName, String? avatarUrl, int? gameLevel}) async {
    try {
      final response = await dio.patch('/users/me', data: {
        if (fullName != null) 'fullName': fullName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (gameLevel != null) 'gameLevel': gameLevel,
      });

      if (response.statusCode == 200) {
        return Right(UserModel.fromJson(response.data));
      } else {
        return const Left(ServerFailure('Failed to update profile'));
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
  Future<Either<Failure, UserEntity>> addCoins(int amount) async {
    try {
      final response = await dio.post('/users/me/coins', data: {
        'amount': amount,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Right(UserModel.fromJson(response.data));
      } else {
        return const Left(ServerFailure('Failed to add coins'));
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
