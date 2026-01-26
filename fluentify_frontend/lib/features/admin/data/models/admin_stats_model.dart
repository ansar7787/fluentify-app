import '../../domain/entities/admin_stats_entity.dart';

class AdminStatsModel extends AdminStatsEntity {
  const AdminStatsModel({
    required super.totalUsers,
    required super.activeMentors,
    required super.pendingMentors,
    required super.totalSessions,
    required super.completedSessions,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    final users = json['users'] ?? {};
    final mentors = json['mentors'] ?? {};
    final sessions = json['sessions'] ?? {};

    return AdminStatsModel(
      totalUsers: users['total'] ?? 0,
      activeMentors: mentors['active'] ?? 0,
      pendingMentors: mentors['pending'] ?? 0,
      totalSessions: sessions['total'] ?? 0,
      completedSessions: sessions['completed'] ?? 0,
    );
  }
}
