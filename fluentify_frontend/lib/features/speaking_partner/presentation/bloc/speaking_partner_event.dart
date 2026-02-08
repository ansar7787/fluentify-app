import 'package:equatable/equatable.dart';
import '../../domain/entities/speaking_scenario_entity.dart';

abstract class SpeakingPartnerEvent extends Equatable {
  const SpeakingPartnerEvent();
  @override
  List<Object?> get props => [];
}

class LoadScenarios extends SpeakingPartnerEvent {}

class StartConversation extends SpeakingPartnerEvent {
  final SpeakingScenarioEntity scenario;
  const StartConversation(this.scenario);
  @override
  List<Object?> get props => [scenario];
}

class SendUserSpeech extends SpeakingPartnerEvent {
  final String transcript;
  const SendUserSpeech(this.transcript);
  @override
  List<Object?> get props => [transcript];
}
