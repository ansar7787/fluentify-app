import 'package:equatable/equatable.dart';

class SentenceChallengeEntity extends Equatable {
  final String id;
  final String correctSentence;
  final List<String> shuffledWords;
  final String hint;
  final String difficulty;

  const SentenceChallengeEntity({
    required this.id,
    required this.correctSentence,
    required this.shuffledWords,
    required this.hint,
    this.difficulty = 'Beginner',
  });

  @override
  List<Object?> get props =>
      [id, correctSentence, shuffledWords, hint, difficulty];
}
