import 'package:equatable/equatable.dart';

class AdminStatsEntity extends Equatable {
  final int totalUsers;
  final int activeMentors;
  final int pendingMentors;
  final int totalSessions;
  final int completedSessions;

  const AdminStatsEntity({
    required this.totalUsers,
    required this.activeMentors,
    required this.pendingMentors,
    required this.totalSessions,
    required this.completedSessions,
  });

  @override
  List<Object?> get props => [
        totalUsers,
        activeMentors,
        pendingMentors,
        totalSessions,
        completedSessions,
      ];
}
