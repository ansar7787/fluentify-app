import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

class GetChatMessagesUseCase {
  final ChatRepository repository;

  GetChatMessagesUseCase(this.repository);

  Stream<ChatMessage> call() {
    return repository.messagesStream;
  }
}
