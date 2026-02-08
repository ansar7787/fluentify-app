import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/session_remote_data_source.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDataSource remoteDataSource;

  SessionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<SessionEntity>>> getSessions() async {
    try {
      final result = await remoteDataSource.getSessions();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
