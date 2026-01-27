import 'package:equatable/equatable.dart';

class RapidFireChallengeEntity extends Equatable {
  final String id;
  final String question;
  final List<String> acceptableAnswers; // User must say one of these
  final int timeLimitSeconds;
  final String difficulty;

  const RapidFireChallengeEntity({
    required this.id,
    required this.question,
    required this.acceptableAnswers,
    this.timeLimitSeconds = 5,
    this.difficulty = 'Beginner',
  });

  @override
  List<Object?> get props =>
      [id, question, acceptableAnswers, timeLimitSeconds, difficulty];
}
