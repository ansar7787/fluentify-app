import 'package:equatable/equatable.dart';

class ReadingChallengeEntity extends Equatable {
  final String id;
  final String title;
  final String passage;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String difficulty;

  const ReadingChallengeEntity({
    required this.id,
    required this.title,
    required this.passage,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.difficulty = 'Beginner',
  });

  @override
  List<Object?> get props =>
      [id, title, passage, question, options, correctOptionIndex, difficulty];
}
