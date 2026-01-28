import '../../../auth/domain/entities/user_entity.dart';

abstract class PeerRepository {
  Stream<Map<String, dynamic>> get matchStream;
  void joinQueue(UserEntity user);
  void leaveQueue();
  void disconnect();
}
