import '../../domain/entities/rapid_fire_challenge_entity.dart';
import '../../domain/entities/rapid_fire_level_entity.dart';

class RapidFireChallengeModel extends RapidFireChallengeEntity {
  const RapidFireChallengeModel({
    required super.id,
    required super.question,
    required super.acceptableAnswers,
    super.timeLimitSeconds = 5,
    super.difficulty = 'Beginner',
  });

  factory RapidFireChallengeModel.fromJson(Map<String, dynamic> json) {
    return RapidFireChallengeModel(
      id: json['id'],
      question: json['question'],
      acceptableAnswers: List<String>.from(json['acceptableAnswers']),
      timeLimitSeconds: json['timeLimitSeconds'] ?? 5,
      difficulty: json['difficulty'] ?? 'Beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'acceptableAnswers': acceptableAnswers,
      'timeLimitSeconds': timeLimitSeconds,
      'difficulty': difficulty,
    };
  }
}

class RapidFireLevelModel extends RapidFireLevelEntity {
  const RapidFireLevelModel({
    required super.level,
    required super.title,
    required List<RapidFireChallengeModel> challenges,
  }) : super(challenges: challenges);

  factory RapidFireLevelModel.fromJson(Map<String, dynamic> json) {
    return RapidFireLevelModel(
      level: json['level'],
      title: json['title'],
      challenges: (json['challenges'] as List)
          .map((e) => RapidFireChallengeModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'title': title,
      'challenges': challenges
          .map((e) => (e as RapidFireChallengeModel).toJson())
          .toList(),
    };
  }
}
