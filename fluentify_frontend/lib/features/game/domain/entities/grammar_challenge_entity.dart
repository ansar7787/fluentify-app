import 'package:equatable/equatable.dart';

class GrammarChallengeEntity extends Equatable {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final String difficulty;

  const GrammarChallengeEntity({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    this.difficulty = 'Beginner',
  });

  @override
  List<Object?> get props =>
      [id, question, options, correctOptionIndex, explanation, difficulty];
}
