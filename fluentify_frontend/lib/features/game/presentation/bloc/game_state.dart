import 'package:equatable/equatable.dart';
import '../../domain/entities/grammar_level_entity.dart';
import '../../domain/entities/speaking_level_entity.dart';
import '../../domain/entities/scramble_level_entity.dart';
import '../../domain/entities/word_match_level_entity.dart';
import '../../domain/entities/typing_level_entity.dart';
import '../../domain/entities/dictation_level_entity.dart';
import '../../domain/entities/reading_level_entity.dart';
import '../../domain/entities/rapid_fire_level_entity.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object> get props => [];
}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GrammarLevelsLoaded extends GameState {
  final List<GrammarLevelEntity> levels;

  const GrammarLevelsLoaded(this.levels);

  @override
  List<Object> get props => [levels];
}

class SpeakingLevelsLoaded extends GameState {
  final List<SpeakingLevelEntity> levels;

  const SpeakingLevelsLoaded(this.levels);

  @override
  List<Object> get props => [levels];
}

class ScrambleLevelsLoaded extends GameState {
  final List<ScrambleLevelEntity> levels;

  const ScrambleLevelsLoaded(this.levels);

  @override
  List<Object> get props => [levels];
}

class WordMatchLevelsLoaded extends GameState {
  final List<WordMatchLevelEntity> levels;
  const WordMatchLevelsLoaded(this.levels);
  @override
  List<Object> get props => [levels];
}

class TypingLevelsLoaded extends GameState {
  final List<TypingLevelEntity> levels;
  const TypingLevelsLoaded(this.levels);
  @override
  List<Object> get props => [levels];
}

class DictationLevelsLoaded extends GameState {
  final List<DictationLevelEntity> levels;
  const DictationLevelsLoaded(this.levels);
  @override
  List<Object> get props => [levels];
}

class ReadingLevelsLoaded extends GameState {
  final List<ReadingLevelEntity> levels;
  const ReadingLevelsLoaded(this.levels);
  @override
  List<Object> get props => [levels];
}

class RapidFireLevelsLoaded extends GameState {
  final List<RapidFireLevelEntity> levels;
  const RapidFireLevelsLoaded(this.levels);
  @override
  List<Object> get props => [levels];
}

class GameError extends GameState {
  final String message;

  const GameError(this.message);

  @override
  List<Object> get props => [message];
}
