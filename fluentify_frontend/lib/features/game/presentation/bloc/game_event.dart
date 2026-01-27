import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class GetGrammarLevelsEvent extends GameEvent {}

class GetSpeakingLevelsEvent extends GameEvent {}

class GetScrambleLevelsEvent extends GameEvent {}
