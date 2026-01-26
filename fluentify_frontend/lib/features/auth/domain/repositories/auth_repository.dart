import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(
      String email, String password, String fullName);
  Future<Either<Failure, UserEntity>> firebaseLogin(String token);
  Future<Either<Failure, UserEntity>> googleLogin();
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<void> logout();
}
