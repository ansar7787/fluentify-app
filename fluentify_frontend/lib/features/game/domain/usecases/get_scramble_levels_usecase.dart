import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/scramble_level_entity.dart';
import '../repositories/game_repository.dart';

class GetScrambleLevelsUseCase
    implements UseCase<List<ScrambleLevelEntity>, NoParams> {
  final GameRepository repository;

  GetScrambleLevelsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ScrambleLevelEntity>>> call(
      NoParams params) async {
    return await repository.getScrambleLevels();
  }
}
