import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_grammar_levels_usecase.dart';
import '../../domain/usecases/get_speaking_levels_usecase.dart';
import '../../domain/usecases/get_scramble_levels_usecase.dart';
import 'game_event.dart';
import 'game_state.dart';

import '../../domain/usecases/get_word_match_levels_usecase.dart';
import '../../domain/usecases/get_typing_levels_usecase.dart';
import '../../domain/usecases/get_dictation_levels_usecase.dart';
import '../../domain/usecases/get_reading_levels_usecase.dart';
import '../../domain/usecases/get_rapid_fire_levels_usecase.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GetGrammarLevelsUseCase getGrammarLevels;
  final GetSpeakingLevelsUseCase getSpeakingLevels;
  final GetScrambleLevelsUseCase getScrambleLevels;
  final GetWordMatchLevelsUseCase getWordMatchLevels;
  final GetTypingLevelsUseCase getTypingLevels;
  final GetDictationLevelsUseCase getDictationLevels;
  final GetReadingLevelsUseCase getReadingLevels;
  final GetRapidFireLevelsUseCase getRapidFireLevels;

  GameBloc({
    required this.getGrammarLevels,
    required this.getSpeakingLevels,
    required this.getScrambleLevels,
    required this.getWordMatchLevels,
    required this.getTypingLevels,
    required this.getDictationLevels,
    required this.getReadingLevels,
    required this.getRapidFireLevels,
  }) : super(GameInitial()) {
    on<GetGrammarLevelsEvent>(_onGetGrammarLevels);
    on<GetSpeakingLevelsEvent>(_onGetSpeakingLevels);
    on<GetScrambleLevelsEvent>(_onGetScrambleLevels);
    on<GetWordMatchLevelsEvent>(_onGetWordMatchLevels);
    on<GetTypingLevelsEvent>(_onGetTypingLevels);
    on<GetDictationLevelsEvent>(_onGetDictationLevels);
    on<GetReadingLevelsEvent>(_onGetReadingLevels);
    on<GetRapidFireLevelsEvent>(_onGetRapidFireLevels);
  }

  Future<void> _onGetGrammarLevels(
    GetGrammarLevelsEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());
    final result = await getGrammarLevels(NoParams());
    result.fold(
      (failure) => emit(const GameError('Failed to load grammar levels')),
      (levels) => emit(GrammarLevelsLoaded(levels)),
    );
  }

  Future<void> _onGetSpeakingLevels(
    GetSpeakingLevelsEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());
    final result = await getSpeakingLevels(NoParams());
    result.fold(
      (failure) => emit(const GameError('Failed to load speaking levels')),
      (levels) => emit(SpeakingLevelsLoaded(levels)),
    );
  }

  Future<void> _onGetScrambleLevels(
    GetScrambleLevelsEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());
    final result = await getScrambleLevels(NoParams());
    result.fold(
      (failure) => emit(const GameError('Failed to load scramble levels')),
      (levels) => emit(ScrambleLevelsLoaded(levels)),
    );
  }

  Future<void> _onGetWordMatchLevels(
    GetWordMatchLevelsEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());
    final result = await getWordMatchLevels(NoParams());
    result.fold(
      (failure) => emit(const GameError('Failed to load Word Match levels')),
      (levels) => emit(WordMatchLevelsLoaded(levels)),
    );
  }

  Future<void> _onGetTypingLevels(
    GetTypingLevelsEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());
    final result = await getTypingLevels(NoParams());
    result.fold(
      (failure) => emit(const GameError('Failed to load Typing levels')),
      (levels) => emit(TypingLevelsLoaded(levels)),
    );
  }

  Future<void> _onGetDictationLevels(
    GetDictationLevelsEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());
    final result = await getDictationLevels(NoParams());
    result.fold(
      (failure) => emit(const GameError('Failed to load Dictation levels')),
      (levels) => emit(DictationLevelsLoaded(levels)),
    );
  }

  Future<void> _onGetReadingLevels(
    GetReadingLevelsEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());
    final result = await getReadingLevels(NoParams());
    result.fold(
      (failure) => emit(const GameError('Failed to load Reading levels')),
      (levels) => emit(ReadingLevelsLoaded(levels)),
    );
  }

  Future<void> _onGetRapidFireLevels(
    GetRapidFireLevelsEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());
    final result = await getRapidFireLevels(NoParams());
    result.fold(
      (failure) => emit(const GameError('Failed to load Rapid Fire levels')),
      (levels) => emit(RapidFireLevelsLoaded(levels)),
    );
  }
}
