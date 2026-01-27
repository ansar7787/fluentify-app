import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reading_level_entity.dart';
import '../repositories/game_repository.dart';

class GetReadingLevelsUseCase
    implements UseCase<List<ReadingLevelEntity>, NoParams> {
  final GameRepository repository;

  GetReadingLevelsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ReadingLevelEntity>>> call(
      NoParams params) async {
    return await repository.getReadingLevels();
  }
}
