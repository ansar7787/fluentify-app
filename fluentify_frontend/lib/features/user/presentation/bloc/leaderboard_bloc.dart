import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/usecases/get_leaderboard_usecase.dart';
import '../../domain/usecases/get_user_rank_usecase.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final GetLeaderboardUseCase getLeaderboardUseCase;
  final GetUserRankUseCase getUserRankUseCase;

  LeaderboardBloc({
    required this.getLeaderboardUseCase,
    required this.getUserRankUseCase,
  }) : super(LeaderboardInitial()) {
    on<GetLeaderboardEvent>((event, emit) async {
      emit(LeaderboardLoading());

      final results = await Future.wait<dynamic>([
        getLeaderboardUseCase(GetLeaderboardParams(limit: event.limit)),
        getUserRankUseCase(NoParams()),
      ]);

      final leaderboardResult = results[0] as Either<Failure, List<UserEntity>>;
      final rankResult = results[1] as Either<Failure, int>;

      leaderboardResult.fold(
        (failure) => emit(LeaderboardError(failure.message)),
        (rankings) {
          int rank = 0;
          rankResult.fold(
            (l) => null, // Ignore rank failure or set default
            (r) => rank = r,
          );
          emit(LeaderboardLoaded(rankings, rank));
        },
      );
    });
  }
}
