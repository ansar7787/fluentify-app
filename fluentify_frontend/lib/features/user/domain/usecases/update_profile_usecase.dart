import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/user_repository.dart';

class UpdateProfileUseCase {
  final UserRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(
      {String? fullName, String? avatarUrl}) async {
    return await repository.updateProfile(
        fullName: fullName, avatarUrl: avatarUrl);
  }
}
