import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.mentorId,
    required super.scheduledAt,
    super.completedAt,
    required super.durationMinutes,
    required super.status,
    super.notes,
    required super.sessionCost,
    required super.coinsSpent,
    super.sessionRecordingUrl,
    super.meetingLink,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      mentorId: json['mentor_id'] ?? '',
      scheduledAt: DateTime.parse(
          json['scheduled_at'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      durationMinutes: json['duration_minutes'] ?? 60,
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      sessionCost: (json['session_cost'] as num?)?.toDouble() ?? 0.0,
      coinsSpent: json['coins_spent'] ?? 0,
      sessionRecordingUrl: json['session_recording_url'],
      meetingLink: json['meeting_link'],
    );
  }
}
