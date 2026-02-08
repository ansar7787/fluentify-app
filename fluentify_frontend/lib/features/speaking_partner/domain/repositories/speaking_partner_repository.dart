import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/speaking_scenario_entity.dart';
import '../entities/chat_turn_entity.dart';

abstract class SpeakingPartnerRepository {
  Future<Either<Failure, List<SpeakingScenarioEntity>>> getScenarios();
  Future<Either<Failure, ChatTurnEntity>> processTurn({
    required String scenarioId,
    required String transcript,
    required List<Map<String, String>> history,
  });
}
