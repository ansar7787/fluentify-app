import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/peer_repository.dart';

class JoinQueueUseCase {
  final PeerRepository repository;
  JoinQueueUseCase(this.repository);

  void call(UserEntity user) => repository.joinQueue(user);
}

class LeaveQueueUseCase {
  final PeerRepository repository;
  LeaveQueueUseCase(this.repository);

  void call() => repository.leaveQueue();
}

class GetMatchStreamUseCase {
  final PeerRepository repository;
  GetMatchStreamUseCase(this.repository);

  Stream<Map<String, dynamic>> call() => repository.matchStream;
}
