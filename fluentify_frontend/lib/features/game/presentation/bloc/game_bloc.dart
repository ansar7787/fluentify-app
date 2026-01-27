import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_grammar_levels_usecase.dart';
import '../../domain/usecases/get_speaking_levels_usecase.dart';
import '../../domain/usecases/get_scramble_levels_usecase.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GetGrammarLevelsUseCase getGrammarLevels;
  final GetSpeakingLevelsUseCase getSpeakingLevels;
  final GetScrambleLevelsUseCase getScrambleLevels;

  GameBloc({
    required this.getGrammarLevels,
    required this.getSpeakingLevels,
    required this.getScrambleLevels,
  }) : super(GameInitial()) {
    on<GetGrammarLevelsEvent>(_onGetGrammarLevels);
    on<GetSpeakingLevelsEvent>(_onGetSpeakingLevels);
    on<GetScrambleLevelsEvent>(_onGetScrambleLevels);
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
}
