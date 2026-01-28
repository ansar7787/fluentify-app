import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/session_repository.dart';

class GetSessionsUseCase {
  final SessionRepository repository;

  GetSessionsUseCase(this.repository);

  Future<List<SessionEntity>> call() {
    return repository.getSessions();
  }
}
