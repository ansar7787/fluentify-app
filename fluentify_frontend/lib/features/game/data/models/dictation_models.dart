import '../../domain/entities/dictation_challenge_entity.dart';
import '../../domain/entities/dictation_level_entity.dart';

class DictationChallengeModel extends DictationChallengeEntity {
  const DictationChallengeModel({
    required super.id,
    required super.correctText,
    super.audioUrl = '',
    required super.hint,
    super.difficulty = 'Beginner',
  });

  factory DictationChallengeModel.fromJson(Map<String, dynamic> json) {
    return DictationChallengeModel(
      id: json['id'],
      correctText: json['correctText'],
      audioUrl: json['audioUrl'] ?? '',
      hint: json['hint'],
      difficulty: json['difficulty'] ?? 'Beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'correctText': correctText,
      'audioUrl': audioUrl,
      'hint': hint,
      'difficulty': difficulty,
    };
  }
}

class DictationLevelModel extends DictationLevelEntity {
  const DictationLevelModel({
    required super.level,
    required super.title,
    required List<DictationChallengeModel> challenges,
  }) : super(challenges: challenges);

  factory DictationLevelModel.fromJson(Map<String, dynamic> json) {
    return DictationLevelModel(
      level: json['level'],
      title: json['title'],
      challenges: (json['challenges'] as List)
          .map((e) => DictationChallengeModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'title': title,
      'challenges': challenges
          .map((e) => (e as DictationChallengeModel).toJson())
          .toList(),
    };
  }
}
