import 'package:equatable/equatable.dart';

class MissionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String level;
  final int coins;
  final String? content;
  final bool isCompleted;

  const MissionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.coins,
    this.content,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props =>
      [id, title, description, level, coins, content, isCompleted];
}

class MissionFeedbackEntity extends Equatable {
  final String feedback;
  final String transcript;
  final double fluencyScore;
  final double grammarScore;
  final double vocabularyScore;
  final double pronunciationScore;

  const MissionFeedbackEntity({
    required this.feedback,
    required this.transcript,
    required this.fluencyScore,
    required this.grammarScore,
    required this.vocabularyScore,
    required this.pronunciationScore,
  });

  @override
  List<Object?> get props => [
        feedback,
        transcript,
        fluencyScore,
        grammarScore,
        vocabularyScore,
        pronunciationScore
      ];
}

class MissionSubmissionResultEntity extends Equatable {
  final double score;
  final MissionFeedbackEntity feedback;

  const MissionSubmissionResultEntity({
    required this.score,
    required this.feedback,
  });

  @override
  List<Object?> get props => [score, feedback];
}
