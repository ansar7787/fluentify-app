import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.profileImage,
    required super.coins,
    required super.streakCount,
    required super.level,
    super.missionsCompleted = 0,
    super.gameLevel = 1,
    super.grammarLevel = 1,
    super.speakingLevel = 1,
    super.subscriptionPlan = 'free',
    super.subscriptionExpiry,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      profileImage: json['profileImage'] ?? json['avatarUrl'],
      coins: json['coins'] ?? 0,
      streakCount: json['streakCount'] ?? 0,
      level: json['level'] ?? json['cefrLevel'] ?? 'Beginner',
      missionsCompleted: json['missionsCompleted'] ?? 0,
      gameLevel: json['gameLevel'] ?? 1,
      grammarLevel: json['grammarLevel'] ?? 1,
      speakingLevel: json['speakingLevel'] ?? 1,
      subscriptionPlan: json['subscriptionPlan'] ?? 'free',
      subscriptionExpiry: json['subscriptionExpiry'] != null
          ? DateTime.parse(json['subscriptionExpiry'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'profileImage': profileImage,
      'coins': coins,
      'streakCount': streakCount,
      'level': level,
      'missionsCompleted': missionsCompleted,
      'gameLevel': gameLevel,
      'grammarLevel': grammarLevel,
      'speakingLevel': speakingLevel,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
    };
  }
}
