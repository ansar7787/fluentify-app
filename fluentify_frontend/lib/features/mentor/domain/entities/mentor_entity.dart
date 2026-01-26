import 'package:equatable/equatable.dart';

class MentorEntity extends Equatable {
  final String id;
  final String userId;
  final String specialization;
  final List<String> languages;
  final List<String> certifications;
  final String bio;
  final double hourlyRate;
  final double averageRating;
  final int totalReviews;
  final int totalSessionsCompleted;
  final int totalEarnings;
  final bool isVerified;
  final bool isActive;
  final List<String> availableSlots;
  final DateTime createdAt;

  const MentorEntity({
    required this.id,
    required this.userId,
    required this.specialization,
    required this.languages,
    required this.certifications,
    required this.bio,
    required this.hourlyRate,
    required this.averageRating,
    required this.totalReviews,
    required this.totalSessionsCompleted,
    required this.totalEarnings,
    required this.isVerified,
    required this.isActive,
    required this.availableSlots,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        specialization,
        languages,
        certifications,
        bio,
        hourlyRate,
        averageRating,
        totalReviews,
        totalSessionsCompleted,
        totalEarnings,
        isVerified,
        isActive,
        availableSlots,
        createdAt,
      ];
}
