import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../datasources/game_local_data_source.dart';
import '../../domain/entities/grammar_level_entity.dart';
import '../../domain/entities/speaking_level_entity.dart';
import '../../domain/entities/scramble_level_entity.dart';
import '../../domain/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  final GameLocalDataSource localDataSource;

  GameRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<GrammarLevelEntity>>> getGrammarLevels() async {
    try {
      final levels = await localDataSource.getGrammarLevels();
      return Right(levels);
    } catch (e) {
      return Left(CacheFailure('Failed to load grammar levels'));
    }
  }

  @override
  Future<Either<Failure, List<SpeakingLevelEntity>>> getSpeakingLevels() async {
    try {
      final levels = await localDataSource.getSpeakingLevels();
      return Right(levels);
    } catch (e) {
      return Left(CacheFailure('Failed to load speaking levels'));
    }
  }

  @override
  Future<Either<Failure, List<ScrambleLevelEntity>>> getScrambleLevels() async {
    try {
      final levels = await localDataSource.getScrambleLevels();
      return Right(levels);
    } catch (e) {
      return Left(CacheFailure('Failed to load scramble levels'));
    }
  }
}
