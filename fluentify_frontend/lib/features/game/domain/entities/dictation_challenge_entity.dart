import 'package:equatable/equatable.dart';

class DictationChallengeEntity extends Equatable {
  final String id;
  final String correctText;
  final String audioUrl; // Can be empty if using TTS
  final String hint;
  final String difficulty;

  const DictationChallengeEntity({
    required this.id,
    required this.correctText,
    this.audioUrl = '',
    required this.hint,
    this.difficulty = 'Beginner',
  });

  @override
  List<Object?> get props => [id, correctText, audioUrl, hint, difficulty];
}
