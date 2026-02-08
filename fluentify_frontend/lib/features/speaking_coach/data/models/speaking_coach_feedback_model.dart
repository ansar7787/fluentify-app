import '../../domain/entities/speaking_coach_feedback_entity.dart';

class SpeakingCorrectionModel extends SpeakingCorrectionEntity {
  const SpeakingCorrectionModel({
    required super.original,
    required super.corrected,
    required super.reason,
  });

  factory SpeakingCorrectionModel.fromJson(Map<String, dynamic> json) {
    return SpeakingCorrectionModel(
      original: (json['original'] ?? '').toString(),
      corrected: (json['corrected'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
    );
  }
}

class SpeakingDrillModel extends SpeakingDrillEntity {
  const SpeakingDrillModel({
    required super.title,
    required super.instruction,
    required super.durationMinutes,
  });

  factory SpeakingDrillModel.fromJson(Map<String, dynamic> json) {
    return SpeakingDrillModel(
      title: (json['title'] ?? '').toString(),
      instruction: (json['instruction'] ?? '').toString(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
    );
  }
}

class SpeakingPlanDayModel extends SpeakingPlanDayEntity {
  const SpeakingPlanDayModel({
    required super.day,
    required super.focus,
    required super.task,
  });

  factory SpeakingPlanDayModel.fromJson(Map<String, dynamic> json) {
    return SpeakingPlanDayModel(
      day: (json['day'] ?? '').toString(),
      focus: (json['focus'] ?? '').toString(),
      task: (json['task'] ?? '').toString(),
    );
  }
}

class SpeakingCoachFeedbackModel extends SpeakingCoachFeedbackEntity {
  const SpeakingCoachFeedbackModel({
    required super.overallBand,
    required super.fluency,
    required super.grammar,
    required super.vocabulary,
    required super.pronunciation,
    required super.summary,
    required super.strengths,
    required super.priorities,
    required super.corrections,
    required super.drills,
    required super.weeklyPlan,
    required super.nextPrompt,
  });

  factory SpeakingCoachFeedbackModel.fromJson(Map<String, dynamic> json) {
    List<String> toStringList(dynamic value) {
      if (value is List) {
        return value.map((item) => item.toString()).toList();
      }
      return const [];
    }

    List<T> toModelList<T>(
      dynamic value,
      T Function(Map<String, dynamic>) fromJson,
    ) {
      if (value is List) {
        return value
            .whereType<Map>()
            .map((item) => fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return const [];
    }

    return SpeakingCoachFeedbackModel(
      overallBand: (json['overallBand'] as num?)?.toDouble() ?? 0,
      fluency: (json['fluency'] as num?)?.toDouble() ?? 0,
      grammar: (json['grammar'] as num?)?.toDouble() ?? 0,
      vocabulary: (json['vocabulary'] as num?)?.toDouble() ?? 0,
      pronunciation: (json['pronunciation'] as num?)?.toDouble() ?? 0,
      summary: (json['summary'] ?? '').toString(),
      strengths: toStringList(json['strengths']),
      priorities: toStringList(json['priorities']),
      corrections:
          toModelList(json['corrections'], SpeakingCorrectionModel.fromJson),
      drills: toModelList(json['drills'], SpeakingDrillModel.fromJson),
      weeklyPlan:
          toModelList(json['weeklyPlan'], SpeakingPlanDayModel.fromJson),
      nextPrompt: (json['nextPrompt'] ?? '').toString(),
    );
  }
}
