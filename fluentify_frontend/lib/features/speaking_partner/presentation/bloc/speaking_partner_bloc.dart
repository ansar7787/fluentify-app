import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_scenarios_use_case.dart';
import '../../domain/use_cases/process_turn_use_case.dart';
import '../../domain/entities/chat_turn_entity.dart';
import 'speaking_partner_event.dart';
import 'speaking_partner_state.dart';

class SpeakingPartnerBloc
    extends Bloc<SpeakingPartnerEvent, SpeakingPartnerState> {
  final GetScenariosUseCase getScenarios;
  final ProcessTurnUseCase processTurn;

  SpeakingPartnerBloc({
    required this.getScenarios,
    required this.processTurn,
  }) : super(SpeakingPartnerInitial()) {
    on<LoadScenarios>(_onLoadScenarios);
    on<StartConversation>(_onStartConversation);
    on<SendUserSpeech>(_onSendUserSpeech);
  }

  Future<void> _onLoadScenarios(
      LoadScenarios event, Emitter<SpeakingPartnerState> emit) async {
    emit(ScenariosLoading());
    final result = await getScenarios();
    result.fold(
      (failure) => emit(SpeakingPartnerError(failure.message)),
      (scenarios) => emit(ScenariosLoaded(scenarios)),
    );
  }

  void _onStartConversation(
      StartConversation event, Emitter<SpeakingPartnerState> emit) {
    emit(ConversationActive(
      scenario: event.scenario,
      messages: [
        ChatMessageEntity(
          content:
              "Hello! I'm your ${event.scenario.aiRole}. Shall we begin our ${event.scenario.title}?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    ));
  }

  Future<void> _onSendUserSpeech(
      SendUserSpeech event, Emitter<SpeakingPartnerState> emit) async {
    if (state is! ConversationActive) return;
    final currentState = state as ConversationActive;

    emit(ConversationActive(
      scenario: currentState.scenario,
      messages: currentState.messages,
      isAITyping: true,
    ));

    final history = currentState.messages
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.content,
            })
        .toList();

    final result = await processTurn(ProcessTurnParams(
      scenarioId: currentState.scenario.id,
      transcript: event.transcript, // This is audioPath
      history: history,
    ));

    result.fold(
      (failure) => emit(SpeakingPartnerError(failure.message)),
      (turn) {
        final userMessage = ChatMessageEntity(
          content: turn.userTranscript,
          isUser: true,
          timestamp: DateTime.now(),
        );

        final aiMessage = ChatMessageEntity(
          content: turn.response,
          isUser: false,
          timestamp: DateTime.now(),
        );

        emit(ConversationActive(
          scenario: currentState.scenario,
          messages: List<ChatMessageEntity>.from(currentState.messages)
            ..add(userMessage)
            ..add(aiMessage),
          isAITyping: false,
        ));
      },
    );
  }
}
