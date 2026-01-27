import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/word_match_level_entity.dart';
import '../repositories/game_repository.dart';

class GetWordMatchLevelsUseCase
    implements UseCase<List<WordMatchLevelEntity>, NoParams> {
  final GameRepository repository;

  GetWordMatchLevelsUseCase(this.repository);

  @override
  Future<Either<Failure, List<WordMatchLevelEntity>>> call(
      NoParams params) async {
    return await repository.getWordMatchLevels();
  }
}
