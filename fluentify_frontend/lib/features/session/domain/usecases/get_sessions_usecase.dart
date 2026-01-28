import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/session_repository.dart';

class GetSessionsUseCase {
  final SessionRepository repository;

  GetSessionsUseCase(this.repository);

  Future<Either<Failure, List<SessionEntity>>> call() {
    return repository.getSessions();
  }
}
