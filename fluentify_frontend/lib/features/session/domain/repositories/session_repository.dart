import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/session_entity.dart';

abstract class SessionRepository {
  Future<Either<Failure, List<SessionEntity>>> getSessions();
}
