import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntity>> getProfile();
  Future<Either<Failure, List<UserEntity>>> getLeaderboard({int limit = 20});
  Future<Either<Failure, int>> getUserRank();
  Future<Either<Failure, UserEntity>> updateProfile({
    String? fullName,
    String? avatarUrl,
    int? gameLevel,
    int? grammarLevel,
    int? speakingLevel,
    int? wordMatchLevel,
    int? typingLevel,
    int? dictationLevel,
    int? readingLevel,
    int? rapidFireLevel,
  });
  Future<Either<Failure, UserEntity>> addCoins(int amount);
}
