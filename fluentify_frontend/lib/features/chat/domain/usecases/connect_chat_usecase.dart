import '../../domain/repositories/chat_repository.dart';

class ConnectChatUseCase {
  final ChatRepository repository;

  ConnectChatUseCase(this.repository);

  void call(String room) {
    repository.connectToRoom(room);
  }
}
