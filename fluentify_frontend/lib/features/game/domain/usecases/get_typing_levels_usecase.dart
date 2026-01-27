import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/typing_level_entity.dart';
import '../repositories/game_repository.dart';

class GetTypingLevelsUseCase
    implements UseCase<List<TypingLevelEntity>, NoParams> {
  final GameRepository repository;

  GetTypingLevelsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TypingLevelEntity>>> call(NoParams params) async {
    return await repository.getTypingLevels();
  }
}
