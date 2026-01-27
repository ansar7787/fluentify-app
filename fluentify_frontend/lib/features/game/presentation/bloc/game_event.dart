import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class GetGrammarLevelsEvent extends GameEvent {}

class GetSpeakingLevelsEvent extends GameEvent {}

class GetScrambleLevelsEvent extends GameEvent {}

class GetWordMatchLevelsEvent extends GameEvent {}

class GetTypingLevelsEvent extends GameEvent {}

class GetDictationLevelsEvent extends GameEvent {}

class GetReadingLevelsEvent extends GameEvent {}

class GetRapidFireLevelsEvent extends GameEvent {}
