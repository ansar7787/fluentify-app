import '../entities/chat_message.dart';

abstract class ChatRepository {
  Stream<ChatMessage> get messagesStream;
  void connectToRoom(String room);
  void sendMessage(
      String room, String message, String senderName, String senderId);
  void disconnect();
}
