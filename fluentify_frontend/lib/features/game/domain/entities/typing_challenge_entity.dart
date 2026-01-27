import 'package:equatable/equatable.dart';

class TypingChallengeEntity extends Equatable {
  final String id;
  final String textToType; // Single word or sentence
  final int timeLimitSeconds;
  final String difficulty;

  const TypingChallengeEntity({
    required this.id,
    required this.textToType,
    required this.timeLimitSeconds,
    this.difficulty = 'Beginner',
  });

  @override
  List<Object?> get props => [id, textToType, timeLimitSeconds, difficulty];
}
