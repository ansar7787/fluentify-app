import '../../domain/entities/sentence_challenge_entity.dart';

class SentenceChallengeModel extends SentenceChallengeEntity {
  const SentenceChallengeModel({
    required super.id,
    required super.correctSentence,
    required super.shuffledWords,
    required super.hint,
    super.difficulty = 'Beginner',
  });

  factory SentenceChallengeModel.fromJson(Map<String, dynamic> json) {
    return SentenceChallengeModel(
      id: json['id'],
      correctSentence: json['correctSentence'],
      shuffledWords: List<String>.from(json['shuffledWords']),
      hint: json['hint'],
      difficulty: json['difficulty'] ?? 'Beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'correctSentence': correctSentence,
      'shuffledWords': shuffledWords,
      'hint': hint,
      'difficulty': difficulty,
    };
  }
}
