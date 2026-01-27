import 'package:equatable/equatable.dart';
import '../../domain/entities/grammar_level_entity.dart';
import '../../domain/entities/speaking_level_entity.dart';
import '../../domain/entities/scramble_level_entity.dart';

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

class GameError extends GameState {
  final String message;

  const GameError(this.message);

  @override
  List<Object> get props => [message];
}
