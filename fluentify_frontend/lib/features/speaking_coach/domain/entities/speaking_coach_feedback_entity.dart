import 'package:equatable/equatable.dart';

class SpeakingCorrectionEntity extends Equatable {
  final String original;
  final String corrected;
  final String reason;

  const SpeakingCorrectionEntity({
    required this.original,
    required this.corrected,
    required this.reason,
  });

  @override
  List<Object?> get props => [original, corrected, reason];
}

class SpeakingDrillEntity extends Equatable {
  final String title;
  final String instruction;
  final int durationMinutes;

  const SpeakingDrillEntity({
    required this.title,
    required this.instruction,
    required this.durationMinutes,
  });

  @override
  List<Object?> get props => [title, instruction, durationMinutes];
}

class SpeakingPlanDayEntity extends Equatable {
  final String day;
  final String focus;
  final String task;

  const SpeakingPlanDayEntity({
    required this.day,
    required this.focus,
    required this.task,
  });

  @override
  List<Object?> get props => [day, focus, task];
}

class SpeakingCoachFeedbackEntity extends Equatable {
  final double overallBand;
  final double fluency;
  final double grammar;
  final double vocabulary;
  final double pronunciation;
  final String summary;
  final List<String> strengths;
  final List<String> priorities;
  final List<SpeakingCorrectionEntity> corrections;
  final List<SpeakingDrillEntity> drills;
  final List<SpeakingPlanDayEntity> weeklyPlan;
  final String nextPrompt;

  const SpeakingCoachFeedbackEntity({
    required this.overallBand,
    required this.fluency,
    required this.grammar,
    required this.vocabulary,
    required this.pronunciation,
    required this.summary,
    required this.strengths,
    required this.priorities,
    required this.corrections,
    required this.drills,
    required this.weeklyPlan,
    required this.nextPrompt,
  });

  @override
  List<Object?> get props => [
        overallBand,
        fluency,
        grammar,
        vocabulary,
        pronunciation,
        summary,
        strengths,
        priorities,
        corrections,
        drills,
        weeklyPlan,
        nextPrompt,
      ];
}
