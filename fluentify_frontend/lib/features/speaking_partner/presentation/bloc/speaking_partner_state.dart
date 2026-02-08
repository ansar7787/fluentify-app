import 'package:equatable/equatable.dart';
import '../../domain/entities/speaking_scenario_entity.dart';
import '../../domain/entities/chat_turn_entity.dart';

abstract class SpeakingPartnerState extends Equatable {
  const SpeakingPartnerState();
  @override
  List<Object?> get props => [];
}

class SpeakingPartnerInitial extends SpeakingPartnerState {}

class ScenariosLoading extends SpeakingPartnerState {}

class ScenariosLoaded extends SpeakingPartnerState {
  final List<SpeakingScenarioEntity> scenarios;
  const ScenariosLoaded(this.scenarios);
  @override
  List<Object?> get props => [scenarios];
}

class ConversationActive extends SpeakingPartnerState {
  final SpeakingScenarioEntity scenario;
  final List<ChatMessageEntity> messages;
  final bool isAITyping;

  const ConversationActive({
    required this.scenario,
    required this.messages,
    this.isAITyping = false,
  });

  @override
  List<Object?> get props => [scenario, messages, isAITyping];
}

class SpeakingPartnerError extends SpeakingPartnerState {
  final String message;
  const SpeakingPartnerError(this.message);
  @override
  List<Object?> get props => [message];
}
