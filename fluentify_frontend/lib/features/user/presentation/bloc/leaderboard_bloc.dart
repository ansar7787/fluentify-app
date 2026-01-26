import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_leaderboard_usecase.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final GetLeaderboardUseCase getLeaderboardUseCase;

  LeaderboardBloc({required this.getLeaderboardUseCase})
      : super(LeaderboardInitial()) {
    on<GetLeaderboardEvent>((event, emit) async {
      emit(LeaderboardLoading());

      final result =
          await getLeaderboardUseCase(GetLeaderboardParams(limit: event.limit));

      result.fold(
        (failure) => emit(LeaderboardError(failure.message)),
        (rankings) => emit(LeaderboardLoaded(rankings)),
      );
    });
  }
}
