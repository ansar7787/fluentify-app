import 'package:equatable/equatable.dart';

class SpeakingChallengeEntity extends Equatable {
  final String id;
  final String title;
  final String prompt;
  final String? imageUrl;
  final int durationSeconds;
  final String difficulty;

  const SpeakingChallengeEntity({
    required this.id,
    required this.title,
    required this.prompt,
    this.imageUrl,
    this.durationSeconds = 60,
    this.difficulty = 'Beginner',
  });

  @override
  List<Object?> get props =>
      [id, title, prompt, imageUrl, durationSeconds, difficulty];
}
