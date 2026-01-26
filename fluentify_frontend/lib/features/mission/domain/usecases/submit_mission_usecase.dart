import 'package:dartz/dartz.dart';
import 'package:fluentify/core/error/failures.dart';
import 'package:fluentify/core/usecases/usecase.dart';
import '../entities/mission_entity.dart';
import '../repositories/mission_repository.dart';

class SubmitMissionParams {
  final String missionId;
  final String audioPath;
  SubmitMissionParams({required this.missionId, required this.audioPath});
}

class SubmitMissionUseCase
    implements UseCase<MissionSubmissionResultEntity, SubmitMissionParams> {
  final MissionRepository repository;
  SubmitMissionUseCase(this.repository);

  @override
  Future<Either<Failure, MissionSubmissionResultEntity>> call(
      SubmitMissionParams params) async {
    return await repository.submitMission(params.missionId, params.audioPath);
  }
}
