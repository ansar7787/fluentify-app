import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/chat_turn_entity.dart';
import '../../domain/entities/speaking_scenario_entity.dart';
import '../../domain/repositories/speaking_partner_repository.dart';
import '../data_sources/speaking_partner_remote_datasource.dart';

class SpeakingPartnerRepositoryImpl implements SpeakingPartnerRepository {
  final SpeakingPartnerRemoteDataSource remoteDataSource;

  SpeakingPartnerRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<SpeakingScenarioEntity>>> getScenarios() async {
    try {
      final scenarios = await remoteDataSource.getScenarios();
      return Right(scenarios);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, ChatTurnEntity>> processTurn({
    required String scenarioId,
    required String transcript,
    required List<Map<String, String>> history,
  }) async {
    try {
      final turn = await remoteDataSource.processTurn(
        scenarioId: scenarioId,
        transcript: transcript,
        history: history,
      );
      return Right(turn);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(Object e) {
    if (e is DioException) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Server error';
        return ServerFailure(message.toString());
      }
      return const NetworkFailure('No internet connection');
    }
    return ServerFailure(e.toString());
  }
}
