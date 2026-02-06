import 'package:dartz/dartz.dart';
import 'package:fluentify/core/error/failures.dart';
import '../entities/speaking_coach_feedback_entity.dart';

abstract class SpeakingCoachRepository {
  Future<Either<Failure, SpeakingCoachFeedbackEntity>> analyzeSpeaking({
    required String transcript,
    String? prompt,
    String? learnerLevel,
  });
}
