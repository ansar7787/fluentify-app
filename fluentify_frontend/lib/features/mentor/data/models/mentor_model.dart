import '../../domain/entities/mentor_entity.dart';

class MentorModel extends MentorEntity {
  const MentorModel({
    required super.id,
    required super.userId,
    required super.specialization,
    required super.languages,
    required super.certifications,
    required super.bio,
    required super.hourlyRate,
    required super.averageRating,
    required super.totalReviews,
    required super.totalSessionsCompleted,
    required super.totalEarnings,
    required super.isVerified,
    required super.isActive,
    required super.availableSlots,
    required super.createdAt,
  });

  factory MentorModel.fromJson(Map<String, dynamic> json) {
    return MentorModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ??
          '', // Backend uses snake_case probably? Check entity.
      specialization: json['specialization'] ?? '',
      languages: List<String>.from(json['languages'] ?? []),
      certifications: List<String>.from(json['certifications'] ?? []),
      bio: json['bio'] ?? '',
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      totalSessionsCompleted: json['total_sessions_completed'] ?? 0,
      totalEarnings: json['total_earnings'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      availableSlots: List<String>.from(json['available_slots'] ?? []),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
