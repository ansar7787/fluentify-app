import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_missions_usecase.dart';
import '../../domain/usecases/submit_mission_usecase.dart';
import 'mission_event.dart';
import 'mission_state.dart';

class MissionBloc extends Bloc<MissionEvent, MissionState> {
  final GetMissionsUseCase getMissionsUseCase;
  final SubmitMissionUseCase submitMissionUseCase;

  MissionBloc({
    required this.getMissionsUseCase,
    required this.submitMissionUseCase,
  }) : super(MissionInitial()) {
    on<LoadMissions>(_onLoadMissions);
    on<SubmitMissionAttempt>(_onSubmitMissionAttempt);
  }

  Future<void> _onLoadMissions(
    LoadMissions event,
    Emitter<MissionState> emit,
  ) async {
    emit(MissionsLoading());
    final result = await getMissionsUseCase(event.level);
    result.fold(
      (failure) => emit(MissionError(failure.message)),
      (missions) => emit(MissionsLoaded(missions)),
    );
  }

  Future<void> _onSubmitMissionAttempt(
    SubmitMissionAttempt event,
    Emitter<MissionState> emit,
  ) async {
    emit(MissionSubmitting());
    final result = await submitMissionUseCase(SubmitMissionParams(
      missionId: event.missionId,
      audioPath: event.audioPath,
    ));
    result.fold(
      (failure) => emit(MissionError(failure.message)),
      (data) => emit(MissionSubmitted(data)),
    );
  }
}
