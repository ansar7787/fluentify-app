import 'dart:async';
import '../../../../core/network/chat_service.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/entities/chat_message.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatService _chatService;
  final StreamController<ChatMessage> _messagesController =
      StreamController<ChatMessage>.broadcast();
  String _currentUserId = 'User'; // In real app, get from UserBloc or Auth

  ChatRepositoryImpl(this._chatService);

  @override
  Stream<ChatMessage> get messagesStream => _messagesController.stream;

  @override
  void connectToRoom(String room) {
    _chatService.initSocket();
    _chatService.joinRoom(room);
    _chatService.onMessageReceived((data) {
      final message = ChatMessageModel.fromJson(
          Map<String, dynamic>.from(data), _currentUserId);
      _messagesController.add(message);
    });
  }

  // Helper to update current User (could be improved with injection)
  void setCurrentUser(String userId) {
    _currentUserId = userId;
  }

  @override
  void sendMessage(
      String room, String message, String senderName, String senderId) {
    _chatService.sendMessage(room, message, senderName);
    // Optimistic update if needed, but socket typically echoes or we handle standard echo
  }

  @override
  void disconnect() {
    _chatService.disconnect();
    // _messagesController.close(); // Don't close if you re-use repo, or close on app exit
  }
}
