import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../datasources/game_local_data_source.dart';
import '../datasources/game_remote_data_source.dart';
import '../../domain/entities/grammar_level_entity.dart';
import '../../domain/entities/speaking_level_entity.dart';
import '../../domain/entities/scramble_level_entity.dart';
import '../../domain/entities/word_match_level_entity.dart';
import '../../domain/entities/typing_level_entity.dart';
import '../../domain/entities/dictation_level_entity.dart';
import '../../domain/entities/reading_level_entity.dart';
import '../../domain/entities/rapid_fire_level_entity.dart';
import '../../domain/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  final GameLocalDataSource localDataSource;
  final GameRemoteDataSource remoteDataSource;

  GameRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  Future<Either<Failure, List<T>>> _getLevels<T>(
    Future<List<T>> Function() remoteCall,
    Future<List<T>> Function() localCall,
  ) async {
    try {
      final remoteLevels = await remoteCall();
      if (remoteLevels.isNotEmpty) {
        return Right(remoteLevels);
      }
      throw Exception('Empty remote levels');
    } catch (e) {
      // Fallback to local
      try {
        final localLevels = await localCall();
        return Right(localLevels);
      } catch (e2) {
        return Left(CacheFailure('Failed to load levels: ${e.toString()}'));
      }
    }
  }

  @override
  Future<Either<Failure, List<GrammarLevelEntity>>> getGrammarLevels() async {
    return _getLevels(
      () => remoteDataSource.getGrammarLevels(),
      () => localDataSource.getGrammarLevels(),
    );
  }

  @override
  Future<Either<Failure, List<SpeakingLevelEntity>>> getSpeakingLevels() async {
    return _getLevels(
      () => remoteDataSource.getSpeakingLevels(),
      () => localDataSource.getSpeakingLevels(),
    );
  }

  @override
  Future<Either<Failure, List<ScrambleLevelEntity>>> getScrambleLevels() async {
    return _getLevels(
      () => remoteDataSource.getScrambleLevels(),
      () => localDataSource.getScrambleLevels(),
    );
  }

  @override
  Future<Either<Failure, List<WordMatchLevelEntity>>>
      getWordMatchLevels() async {
    return _getLevels(
      () => remoteDataSource.getWordMatchLevels(),
      () => localDataSource.getWordMatchLevels(),
    );
  }

  @override
  Future<Either<Failure, List<TypingLevelEntity>>> getTypingLevels() async {
    return _getLevels(
      () => remoteDataSource.getTypingLevels(),
      () => localDataSource.getTypingLevels(),
    );
  }

  @override
  Future<Either<Failure, List<DictationLevelEntity>>>
      getDictationLevels() async {
    return _getLevels(
      () => remoteDataSource.getDictationLevels(),
      () => localDataSource.getDictationLevels(),
    );
  }

  @override
  Future<Either<Failure, List<ReadingLevelEntity>>> getReadingLevels() async {
    return _getLevels(
      () => remoteDataSource.getReadingLevels(),
      () => localDataSource.getReadingLevels(),
    );
  }

  @override
  Future<Either<Failure, List<RapidFireLevelEntity>>>
      getRapidFireLevels() async {
    return _getLevels(
      () => remoteDataSource.getRapidFireLevels(),
      () => localDataSource.getRapidFireLevels(),
    );
  }
}
