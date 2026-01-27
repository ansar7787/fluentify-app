import 'package:equatable/equatable.dart';

class WordPairEntity extends Equatable {
  final String word;
  final String match; // Synonym, Antonym, or Definition

  const WordPairEntity({required this.word, required this.match});

  @override
  List<Object?> get props => [word, match];
}

class WordMatchChallengeEntity extends Equatable {
  final String id;
  final String instruction; // e.g., "Match synonyms"
  final List<WordPairEntity> pairs;
  final String difficulty;

  const WordMatchChallengeEntity({
    required this.id,
    required this.instruction,
    required this.pairs,
    this.difficulty = 'Beginner',
  });

  @override
  List<Object?> get props => [id, instruction, pairs, difficulty];
}
