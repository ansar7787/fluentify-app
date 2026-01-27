import '../../domain/entities/typing_challenge_entity.dart';
import '../../domain/entities/typing_level_entity.dart';

class TypingChallengeModel extends TypingChallengeEntity {
  const TypingChallengeModel({
    required super.id,
    required super.textToType,
    required super.timeLimitSeconds,
    super.difficulty = 'Beginner',
  });

  factory TypingChallengeModel.fromJson(Map<String, dynamic> json) {
    return TypingChallengeModel(
      id: json['id'],
      textToType: json['textToType'],
      timeLimitSeconds: json['timeLimitSeconds'],
      difficulty: json['difficulty'] ?? 'Beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'textToType': textToType,
      'timeLimitSeconds': timeLimitSeconds,
      'difficulty': difficulty,
    };
  }
}

class TypingLevelModel extends TypingLevelEntity {
  const TypingLevelModel({
    required super.level,
    required super.title,
    required List<TypingChallengeModel> challenges,
  }) : super(challenges: challenges);

  factory TypingLevelModel.fromJson(Map<String, dynamic> json) {
    return TypingLevelModel(
      level: json['level'],
      title: json['title'],
      challenges: (json['challenges'] as List)
          .map((e) => TypingChallengeModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'title': title,
      'challenges':
          challenges.map((e) => (e as TypingChallengeModel).toJson()).toList(),
    };
  }
}
