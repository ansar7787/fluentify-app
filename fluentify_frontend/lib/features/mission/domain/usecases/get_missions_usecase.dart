import 'package:dartz/dartz.dart';
import 'package:fluentify/core/error/failures.dart';
import 'package:fluentify/core/usecases/usecase.dart';
import '../entities/mission_entity.dart';
import '../repositories/mission_repository.dart';

class GetMissionsUseCase implements UseCase<List<MissionEntity>, String?> {
  final MissionRepository repository;
  GetMissionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MissionEntity>>> call(String? level) async {
    return await repository.getMissions(level: level);
  }
}
