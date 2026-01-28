import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/chat_service.dart';

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

  const ChatSendMessage(
      {required this.room, required this.message, required this.sender});
}

class ChatReceiveMessage extends ChatEvent {
  final Map<String, dynamic> message;
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
  final List<Map<String, dynamic>> messages;
  const ChatLoaded(this.messages);
  @override
  List<Object> get props => [messages];
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;
  final List<Map<String, dynamic>> _messages = [];

  ChatBloc(this._chatService) : super(ChatInitial()) {
    on<ChatConnect>((event, emit) {
      _chatService.initSocket();
      _chatService.joinRoom(event.room);
      _chatService.onMessageReceived((data) {
        add(ChatReceiveMessage(Map<String, dynamic>.from(data)));
      });
      emit(ChatLoaded(List.from(_messages)));
    });

    on<ChatSendMessage>((event, emit) {
      _chatService.sendMessage(event.room, event.message, event.sender);
    });

    on<ChatReceiveMessage>((event, emit) {
      _messages.add(event.message);
      emit(ChatLoaded(List.from(_messages)));
    });
  }

  @override
  Future<void> close() {
    _chatService.disconnect();
    return super.close();
  }
}
