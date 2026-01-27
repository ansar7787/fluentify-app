import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rapid_fire_level_entity.dart';
import '../repositories/game_repository.dart';

class GetRapidFireLevelsUseCase
    implements UseCase<List<RapidFireLevelEntity>, NoParams> {
  final GameRepository repository;

  GetRapidFireLevelsUseCase(this.repository);

  @override
  Future<Either<Failure, List<RapidFireLevelEntity>>> call(
      NoParams params) async {
    return await repository.getRapidFireLevels();
  }
}
