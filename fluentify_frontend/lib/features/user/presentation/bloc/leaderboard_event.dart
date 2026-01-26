import 'package:equatable/equatable.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class GetLeaderboardEvent extends LeaderboardEvent {
  final int limit;

  const GetLeaderboardEvent({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}
