import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_turn_entity.dart';
import '../repositories/speaking_partner_repository.dart';

class ProcessTurnUseCase {
  final SpeakingPartnerRepository repository;
  ProcessTurnUseCase(this.repository);

  Future<Either<Failure, ChatTurnEntity>> call(ProcessTurnParams params) async {
    return await repository.processTurn(
      scenarioId: params.scenarioId,
      transcript: params.transcript,
      history: params.history,
    );
  }
}

class ProcessTurnParams {
  final String scenarioId;
  final String transcript;
  final List<Map<String, String>> history;

  ProcessTurnParams({
    required this.scenarioId,
    required this.transcript,
    required this.history,
  });
}
