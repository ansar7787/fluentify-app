import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/grammar_level_entity.dart';
import '../entities/speaking_level_entity.dart';
import '../entities/scramble_level_entity.dart';

abstract class GameRepository {
  Future<Either<Failure, List<GrammarLevelEntity>>> getGrammarLevels();
  Future<Either<Failure, List<SpeakingLevelEntity>>> getSpeakingLevels();
  Future<Either<Failure, List<ScrambleLevelEntity>>> getScrambleLevels();
}
