import '../../domain/entities/reading_challenge_entity.dart';
import '../../domain/entities/reading_level_entity.dart';

class ReadingChallengeModel extends ReadingChallengeEntity {
  const ReadingChallengeModel({
    required super.id,
    required super.title,
    required super.passage,
    required super.question,
    required super.options,
    required super.correctOptionIndex,
    super.difficulty = 'Beginner',
  });

  factory ReadingChallengeModel.fromJson(Map<String, dynamic> json) {
    return ReadingChallengeModel(
      id: json['id'],
      title: json['title'],
      passage: json['passage'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctOptionIndex: json['correctOptionIndex'],
      difficulty: json['difficulty'] ?? 'Beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'passage': passage,
      'question': question,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'difficulty': difficulty,
    };
  }
}

class ReadingLevelModel extends ReadingLevelEntity {
  const ReadingLevelModel({
    required super.level,
    required super.title,
    required List<ReadingChallengeModel> challenges,
  }) : super(challenges: challenges);

  factory ReadingLevelModel.fromJson(Map<String, dynamic> json) {
    return ReadingLevelModel(
      level: json['level'],
      title: json['title'],
      challenges: (json['challenges'] as List)
          .map((e) => ReadingChallengeModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'title': title,
      'challenges':
          challenges.map((e) => (e as ReadingChallengeModel).toJson()).toList(),
    };
  }
}
