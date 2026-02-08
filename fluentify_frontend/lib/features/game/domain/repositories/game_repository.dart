import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/grammar_level_entity.dart';
import '../entities/speaking_level_entity.dart';
import '../entities/scramble_level_entity.dart';
import '../entities/word_match_level_entity.dart';
import '../entities/typing_level_entity.dart';
import '../entities/dictation_level_entity.dart';
import '../entities/reading_level_entity.dart';
import '../entities/rapid_fire_level_entity.dart';

abstract class GameRepository {
  Future<Either<Failure, List<GrammarLevelEntity>>> getGrammarLevels();
  Future<Either<Failure, List<SpeakingLevelEntity>>> getSpeakingLevels();
  Future<Either<Failure, List<ScrambleLevelEntity>>> getScrambleLevels();
  Future<Either<Failure, List<WordMatchLevelEntity>>> getWordMatchLevels();
  Future<Either<Failure, List<TypingLevelEntity>>> getTypingLevels();
  Future<Either<Failure, List<DictationLevelEntity>>> getDictationLevels();
  Future<Either<Failure, List<ReadingLevelEntity>>> getReadingLevels();
  Future<Either<Failure, List<RapidFireLevelEntity>>> getRapidFireLevels();

  // Admin Methods
  Future<Either<Failure, void>> createGameLevel(Map<String, dynamic> levelData);
  Future<Either<Failure, List<dynamic>>> generateAiContent(
      String gameType, String topic, String level);
}
