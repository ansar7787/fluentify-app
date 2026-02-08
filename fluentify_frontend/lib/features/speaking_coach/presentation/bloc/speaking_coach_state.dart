import 'package:equatable/equatable.dart';
import '../../domain/entities/speaking_coach_feedback_entity.dart';

abstract class SpeakingCoachState extends Equatable {
  const SpeakingCoachState();

  @override
  List<Object?> get props => [];
}

class SpeakingCoachInitial extends SpeakingCoachState {}

class SpeakingCoachLoading extends SpeakingCoachState {}

class SpeakingCoachLoaded extends SpeakingCoachState {
  final SpeakingCoachFeedbackEntity feedback;

  const SpeakingCoachLoaded(this.feedback);

  @override
  List<Object?> get props => [feedback];
}

class SpeakingCoachError extends SpeakingCoachState {
  final String message;

  const SpeakingCoachError(this.message);

  @override
  List<Object?> get props => [message];
}
