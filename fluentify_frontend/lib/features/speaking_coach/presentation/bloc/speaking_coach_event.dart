import 'package:equatable/equatable.dart';

abstract class SpeakingCoachEvent extends Equatable {
  const SpeakingCoachEvent();

  @override
  List<Object?> get props => [];
}

class SpeakingCoachAnalyzeRequested extends SpeakingCoachEvent {
  final String transcript;
  final String? prompt;
  final String? learnerLevel;

  const SpeakingCoachAnalyzeRequested({
    required this.transcript,
    this.prompt,
    this.learnerLevel,
  });

  @override
  List<Object?> get props => [transcript, prompt, learnerLevel];
}
