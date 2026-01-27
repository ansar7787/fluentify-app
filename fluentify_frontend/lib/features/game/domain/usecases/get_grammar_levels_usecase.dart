import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/grammar_level_entity.dart';
import '../repositories/game_repository.dart';

class GetGrammarLevelsUseCase
    implements UseCase<List<GrammarLevelEntity>, NoParams> {
  final GameRepository repository;

  GetGrammarLevelsUseCase(this.repository);

  @override
  Future<Either<Failure, List<GrammarLevelEntity>>> call(
      NoParams params) async {
    return await repository.getGrammarLevels();
  }
}
