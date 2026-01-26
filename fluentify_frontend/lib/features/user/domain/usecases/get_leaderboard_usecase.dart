import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetLeaderboardUseCase
    implements UseCase<List<UserEntity>, GetLeaderboardParams> {
  final UserRepository repository;

  GetLeaderboardUseCase(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(
      GetLeaderboardParams params) async {
    return await repository.getLeaderboard(limit: params.limit);
  }
}

class GetLeaderboardParams {
  final int limit;

  GetLeaderboardParams({this.limit = 20});
}
