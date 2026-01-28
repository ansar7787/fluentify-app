import '../../domain/entities/session_entity.dart';

abstract class SessionRepository {
  Future<List<SessionEntity>> getSessions();
}
