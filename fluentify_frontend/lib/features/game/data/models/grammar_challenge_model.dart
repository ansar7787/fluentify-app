import '../../domain/entities/grammar_challenge_entity.dart';

class GrammarChallengeModel extends GrammarChallengeEntity {
  const GrammarChallengeModel({
    required super.id,
    required super.question,
    required super.options,
    required super.correctOptionIndex,
    required super.explanation,
    super.difficulty = 'Beginner',
  });

  factory GrammarChallengeModel.fromJson(Map<String, dynamic> json) {
    return GrammarChallengeModel(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctOptionIndex: json['correctOptionIndex'],
      explanation: json['explanation'],
      difficulty: json['difficulty'] ?? 'Beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
      'difficulty': difficulty,
    };
  }
}
