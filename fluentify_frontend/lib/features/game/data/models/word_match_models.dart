import '../../domain/entities/word_match_challenge_entity.dart'; // Verify path
import '../../domain/entities/word_match_level_entity.dart';

class WordPairModel extends WordPairEntity {
  const WordPairModel({required super.word, required super.match});

  factory WordPairModel.fromJson(Map<String, dynamic> json) {
    return WordPairModel(
      word: json['word'],
      match: json['match'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'match': match,
    };
  }
}

class WordMatchChallengeModel extends WordMatchChallengeEntity {
  const WordMatchChallengeModel({
    required super.id,
    required super.instruction,
    required List<WordPairModel> pairs,
    super.difficulty = 'Beginner',
  }) : super(pairs: pairs);

  factory WordMatchChallengeModel.fromJson(Map<String, dynamic> json) {
    return WordMatchChallengeModel(
      id: json['id'],
      instruction: json['instruction'],
      pairs: (json['pairs'] as List)
          .map((e) => WordPairModel.fromJson(e))
          .toList(),
      difficulty: json['difficulty'] ?? 'Beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instruction': instruction,
      'pairs': pairs.map((e) => (e as WordPairModel).toJson()).toList(),
      'difficulty': difficulty,
    };
  }
}

class WordMatchLevelModel extends WordMatchLevelEntity {
  const WordMatchLevelModel({
    required super.level,
    required super.title,
    required List<WordMatchChallengeModel> challenges,
  }) : super(challenges: challenges);

  factory WordMatchLevelModel.fromJson(Map<String, dynamic> json) {
    return WordMatchLevelModel(
      level: json['level'],
      title: json['title'],
      challenges: (json['challenges'] as List)
          .map((e) => WordMatchChallengeModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'title': title,
      'challenges': challenges
          .map((e) => (e as WordMatchChallengeModel).toJson())
          .toList(),
    };
  }
}
