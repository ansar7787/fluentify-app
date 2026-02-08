import '../../domain/entities/session_entity.dart';

class SessionModel extends SessionEntity {
  const SessionModel({
    required super.id,
    required super.title,
    required super.mentorName,
    required super.mentorAvatar,
    required super.scheduledAt,
    required super.durationMinutes,
    required super.status,
    super.meetingId,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] ?? '',
      title: json['topic'] ?? 'English Session',
      mentorName: json['mentorName'] ?? 'Fluentify Mentor',
      mentorAvatar: json['mentorAvatar'] ?? '',
      scheduledAt:
          DateTime.tryParse(json['scheduledAt'] ?? '') ?? DateTime.now(),
      durationMinutes: json['duration'] ?? 30,
      status: json['status'] ?? 'active',
      meetingId: json['meetingId'],
    );
  }
}
