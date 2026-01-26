import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String id;
  final String userId;
  final String mentorId;
  final DateTime scheduledAt;
  final DateTime? completedAt;
  final int durationMinutes;
  final String status; // pending, scheduled, completed, cancelled
  final String? notes;
  final double sessionCost;
  final int coinsSpent;
  final String? sessionRecordingUrl;
  final String? meetingLink;

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.mentorId,
    required this.scheduledAt,
    this.completedAt,
    required this.durationMinutes,
    required this.status,
    this.notes,
    required this.sessionCost,
    required this.coinsSpent,
    this.sessionRecordingUrl,
    this.meetingLink,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        mentorId,
        scheduledAt,
        completedAt,
        durationMinutes,
        status,
        notes,
        sessionCost,
        coinsSpent,
        sessionRecordingUrl,
        meetingLink,
      ];
}
