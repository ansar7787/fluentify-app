import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/speaking_level_entity.dart';
import '../repositories/game_repository.dart';

class GetSpeakingLevelsUseCase
    implements UseCase<List<SpeakingLevelEntity>, NoParams> {
  final GameRepository repository;

  GetSpeakingLevelsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SpeakingLevelEntity>>> call(
      NoParams params) async {
    return await repository.getSpeakingLevels();
  }
}
