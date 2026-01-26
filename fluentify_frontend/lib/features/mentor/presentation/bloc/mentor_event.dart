import 'package:equatable/equatable.dart';

abstract class MentorEvent extends Equatable {
  const MentorEvent();

  @override
  List<Object?> get props => [];
}

class GetAllMentorsRequested extends MentorEvent {
  final String? language;
  final String? specialization;
  final double? minRating;

  const GetAllMentorsRequested({
    this.language,
    this.specialization,
    this.minRating,
  });

  @override
  List<Object?> get props => [language, specialization, minRating];
}

class CreateBookingRequested extends MentorEvent {
  final String mentorId;
  final DateTime scheduledAt;
  final int durationMinutes;

  const CreateBookingRequested({
    required this.mentorId,
    required this.scheduledAt,
    required this.durationMinutes,
  });

  @override
  List<Object?> get props => [mentorId, scheduledAt, durationMinutes];
}
