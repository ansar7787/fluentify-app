import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/analyze_speaking_usecase.dart';
import 'speaking_coach_event.dart';
import 'speaking_coach_state.dart';

class SpeakingCoachBloc extends Bloc<SpeakingCoachEvent, SpeakingCoachState> {
  final AnalyzeSpeakingUseCase analyzeSpeakingUseCase;

  SpeakingCoachBloc({required this.analyzeSpeakingUseCase})
      : super(SpeakingCoachInitial()) {
    on<SpeakingCoachAnalyzeRequested>(_onAnalyzeRequested);
  }

  Future<void> _onAnalyzeRequested(
    SpeakingCoachAnalyzeRequested event,
    Emitter<SpeakingCoachState> emit,
  ) async {
    emit(SpeakingCoachLoading());
    final result = await analyzeSpeakingUseCase(
      AnalyzeSpeakingParams(
        transcript: event.transcript,
        prompt: event.prompt,
        learnerLevel: event.learnerLevel,
      ),
    );
    result.fold(
      (failure) => emit(SpeakingCoachError(failure.message)),
      (feedback) => emit(SpeakingCoachLoaded(feedback)),
    );
  }
}
