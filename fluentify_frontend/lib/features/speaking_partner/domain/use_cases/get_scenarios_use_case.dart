import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/speaking_scenario_entity.dart';
import '../repositories/speaking_partner_repository.dart';

class GetScenariosUseCase {
  final SpeakingPartnerRepository repository;
  GetScenariosUseCase(this.repository);

  Future<Either<Failure, List<SpeakingScenarioEntity>>> call() async {
    return await repository.getScenarios();
  }
}
