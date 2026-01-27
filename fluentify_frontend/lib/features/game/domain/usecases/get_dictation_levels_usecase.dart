import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dictation_level_entity.dart';
import '../repositories/game_repository.dart';

class GetDictationLevelsUseCase
    implements UseCase<List<DictationLevelEntity>, NoParams> {
  final GameRepository repository;

  GetDictationLevelsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DictationLevelEntity>>> call(
      NoParams params) async {
    return await repository.getDictationLevels();
  }
}
