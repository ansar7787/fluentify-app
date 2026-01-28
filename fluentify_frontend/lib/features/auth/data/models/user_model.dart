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
    super.wordMatchLevel = 1,
    super.typingLevel = 1,
    super.dictationLevel = 1,
    super.readingLevel = 1,
    super.rapidFireLevel = 1,
    super.subscriptionPlan = 'free',
    super.subscriptionExpiry,
    super.role = 'user',
    super.lastPracticeDate,
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
      wordMatchLevel: json['wordMatchLevel'] ?? 1,
      typingLevel: json['typingLevel'] ?? 1,
      dictationLevel: json['dictationLevel'] ?? 1,
      readingLevel: json['readingLevel'] ?? 1,
      rapidFireLevel: json['rapidFireLevel'] ?? 1,
      subscriptionPlan: json['subscriptionPlan'] ?? 'free',
      subscriptionExpiry: json['subscriptionExpiry'] != null
          ? DateTime.parse(json['subscriptionExpiry'])
          : null,
      role: json['role'] ?? 'user',
      lastPracticeDate: json['lastPracticeDate'] != null
          ? DateTime.tryParse(json['lastPracticeDate'])
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
      'wordMatchLevel': wordMatchLevel,
      'typingLevel': typingLevel,
      'dictationLevel': dictationLevel,
      'readingLevel': readingLevel,
      'rapidFireLevel': rapidFireLevel,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
      'role': role,
    };
  }
}
