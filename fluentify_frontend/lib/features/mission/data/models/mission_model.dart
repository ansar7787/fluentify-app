import '../../domain/entities/mission_entity.dart';

class MissionModel extends MissionEntity {
  const MissionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.level,
    required super.coins,
    super.content,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      level: json['level'] ?? 'Beginner',
      coins: json['coins'] ?? 0,
      content: json['content'],
    );
  }
}

class MissionFeedbackModel extends MissionFeedbackEntity {
  const MissionFeedbackModel({
    required super.feedback,
    required super.transcript,
    required super.fluencyScore,
    required super.grammarScore,
    required super.vocabularyScore,
    required super.pronunciationScore,
  });

  factory MissionFeedbackModel.fromJson(Map<String, dynamic> json) {
    return MissionFeedbackModel(
      feedback: json['feedback'] ?? '',
      transcript: json['transcript'] ?? '',
      fluencyScore: (json['fluencyScore'] as num?)?.toDouble() ?? 0.0,
      grammarScore: (json['grammarScore'] as num?)?.toDouble() ?? 0.0,
      vocabularyScore: (json['vocabularyScore'] as num?)?.toDouble() ?? 0.0,
      pronunciationScore:
          (json['pronunciationScore'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MissionSubmissionResultModel extends MissionSubmissionResultEntity {
  const MissionSubmissionResultModel({
    required super.score,
    required super.feedback,
  });

  factory MissionSubmissionResultModel.fromJson(Map<String, dynamic> json) {
    return MissionSubmissionResultModel(
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      feedback: MissionFeedbackModel.fromJson(json['feedback'] ?? {}),
    );
  }
}
