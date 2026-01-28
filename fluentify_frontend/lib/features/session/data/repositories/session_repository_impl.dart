import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/session_remote_data_source.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDataSource remoteDataSource;

  SessionRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<SessionEntity>> getSessions() async {
    return await remoteDataSource.getSessions();
  }
}
