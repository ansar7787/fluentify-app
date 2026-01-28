import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/connect_chat_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/get_chat_messages_usecase.dart';
import '../../domain/entities/chat_message.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object> get props => [];
}

class ChatConnect extends ChatEvent {
  final String room;
  const ChatConnect(this.room);
}

class ChatSendMessage extends ChatEvent {
  final String room;
  final String message;
  final String sender;
  final String senderId;

  const ChatSendMessage(
      {required this.room,
      required this.message,
      required this.sender,
      required this.senderId});
}

class ChatReceiveMessage extends ChatEvent {
  final ChatMessage message;
  const ChatReceiveMessage(this.message);
}

// State
abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  const ChatLoaded(this.messages);
  @override
  List<Object> get props => [messages];
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ConnectChatUseCase connectChat;
  final SendMessageUseCase sendMessage;
  final GetChatMessagesUseCase getChatMessages;
  final List<ChatMessage> _messages = [];

  ChatBloc({
    required this.connectChat,
    required this.sendMessage,
    required this.getChatMessages,
  }) : super(ChatInitial()) {
    on<ChatConnect>((event, emit) {
      connectChat(event.room);
      getChatMessages().listen((message) {
        add(ChatReceiveMessage(message));
      });
      emit(ChatLoaded(List.from(_messages)));
    });

    on<ChatSendMessage>((event, emit) {
      sendMessage(event.room, event.message, event.sender, event.senderId);
    });

    on<ChatReceiveMessage>((event, emit) {
      _messages.add(event.message);
      emit(ChatLoaded(List.from(_messages)));
    });
  }
}
