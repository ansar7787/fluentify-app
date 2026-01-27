import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../datasources/game_local_data_source.dart';
import '../../domain/entities/grammar_level_entity.dart';
import '../../domain/entities/speaking_level_entity.dart';
import '../../domain/entities/scramble_level_entity.dart';
import '../../domain/repositories/game_repository.dart';

import '../../domain/entities/word_match_level_entity.dart';
import '../../domain/entities/typing_level_entity.dart';
import '../../domain/entities/dictation_level_entity.dart';
import '../../domain/entities/reading_level_entity.dart';
import '../../domain/entities/rapid_fire_level_entity.dart';

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

  @override
  Future<Either<Failure, List<WordMatchLevelEntity>>>
      getWordMatchLevels() async {
    try {
      final levels = await localDataSource.getWordMatchLevels();
      return Right(levels);
    } catch (e) {
      return Left(CacheFailure('Failed to load word match levels'));
    }
  }

  @override
  Future<Either<Failure, List<TypingLevelEntity>>> getTypingLevels() async {
    try {
      final levels = await localDataSource.getTypingLevels();
      return Right(levels);
    } catch (e) {
      return Left(CacheFailure('Failed to load typing levels'));
    }
  }

  @override
  Future<Either<Failure, List<DictationLevelEntity>>>
      getDictationLevels() async {
    try {
      final levels = await localDataSource.getDictationLevels();
      return Right(levels);
    } catch (e) {
      return Left(CacheFailure('Failed to load dictation levels'));
    }
  }

  @override
  Future<Either<Failure, List<ReadingLevelEntity>>> getReadingLevels() async {
    try {
      final levels = await localDataSource.getReadingLevels();
      return Right(levels);
    } catch (e) {
      return Left(CacheFailure('Failed to load reading levels'));
    }
  }

  @override
  Future<Either<Failure, List<RapidFireLevelEntity>>>
      getRapidFireLevels() async {
    try {
      final levels = await localDataSource.getRapidFireLevels();
      return Right(levels);
    } catch (e) {
      return Left(CacheFailure('Failed to load rapid fire levels'));
    }
  }
}
