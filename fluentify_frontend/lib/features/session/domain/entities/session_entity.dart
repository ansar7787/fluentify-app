import 'package:equatable/equatable.dart';

class SessionEntity extends Equatable {
  final String id;
  final String title;
  final String mentorName;
  final String mentorAvatar;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String status; // active, completed, cancelled
  final String? meetingId;

  const SessionEntity({
    required this.id,
    required this.title,
    required this.mentorName,
    required this.mentorAvatar,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    this.meetingId,
  });

  @override
  List<Object?> get props => [id, title, mentorName, scheduledAt, status];
}
