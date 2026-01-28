import '../../domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  void call(String room, String message, String senderName, String senderId) {
    repository.sendMessage(room, message, senderName, senderId);
  }
}
