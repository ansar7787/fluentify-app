import '../../domain/entities/grammar_challenge_entity.dart';

class GrammarChallengeModel extends GrammarChallengeEntity {
  const GrammarChallengeModel({
    required String id,
    required String question,
    required List<String> options,
    required int correctOptionIndex,
    required String explanation,
    String difficulty = 'Beginner',
  }) : super(
          id: id,
          question: question,
          options: options,
          correctOptionIndex: correctOptionIndex,
          explanation: explanation,
          difficulty: difficulty,
        );

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
