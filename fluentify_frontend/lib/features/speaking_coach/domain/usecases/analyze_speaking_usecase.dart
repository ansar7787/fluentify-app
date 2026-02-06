import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fluentify/core/error/failures.dart';
import 'package:fluentify/core/usecases/usecase.dart';
import '../entities/speaking_coach_feedback_entity.dart';
import '../repositories/speaking_coach_repository.dart';

class AnalyzeSpeakingParams extends Equatable {
  final String transcript;
  final String? prompt;
  final String? learnerLevel;

  const AnalyzeSpeakingParams({
    required this.transcript,
    this.prompt,
    this.learnerLevel,
  });

  @override
  List<Object?> get props => [transcript, prompt, learnerLevel];
}

class AnalyzeSpeakingUseCase
    implements UseCase<SpeakingCoachFeedbackEntity, AnalyzeSpeakingParams> {
  final SpeakingCoachRepository repository;

  AnalyzeSpeakingUseCase(this.repository);

  @override
  Future<Either<Failure, SpeakingCoachFeedbackEntity>> call(
      AnalyzeSpeakingParams params) {
    return repository.analyzeSpeaking(
      transcript: params.transcript,
      prompt: params.prompt,
      learnerLevel: params.learnerLevel,
    );
  }
}
