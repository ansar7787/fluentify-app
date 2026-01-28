import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? profileImage;
  final int coins;
  final int streakCount;
  final String level;
  final int missionsCompleted;
  final int gameLevel;
  final int grammarLevel;
  final int speakingLevel;
  final String subscriptionPlan;
  final DateTime? subscriptionExpiry;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.profileImage,
    required this.coins,
    required this.streakCount,
    required this.level,
    this.missionsCompleted = 0,
    this.gameLevel = 1,
    this.grammarLevel = 1,
    this.speakingLevel = 1,
    this.wordMatchLevel = 1,
    this.typingLevel = 1,
    this.dictationLevel = 1,
    this.readingLevel = 1,
    this.rapidFireLevel = 1,
    this.subscriptionPlan = 'free',
    this.subscriptionExpiry,
  });

  final int wordMatchLevel;
  final int typingLevel;
  final int dictationLevel;
  final int readingLevel;
  final int rapidFireLevel;

  bool get isPremium => subscriptionPlan == 'premium';

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        profileImage,
        coins,
        streakCount,
        level,
        missionsCompleted,
        gameLevel,
        grammarLevel,
        speakingLevel,
        wordMatchLevel,
        typingLevel,
        dictationLevel,
        readingLevel,
        rapidFireLevel,
        subscriptionPlan,
        subscriptionExpiry,
      ];
}
