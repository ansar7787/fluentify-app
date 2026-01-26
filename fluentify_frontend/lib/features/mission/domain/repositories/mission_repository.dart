import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/mission_entity.dart';

abstract class MissionRepository {
  Future<Either<Failure, List<MissionEntity>>> getMissions({String? level});
  Future<Either<Failure, MissionSubmissionResultEntity>> submitMission(
      String missionId, String audioPath);
}
