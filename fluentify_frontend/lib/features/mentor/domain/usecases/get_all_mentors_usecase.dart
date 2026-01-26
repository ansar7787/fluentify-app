import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/mentor_entity.dart';
import '../repositories/mentor_repository.dart';

class GetAllMentorsUseCase {
  final MentorRepository repository;

  GetAllMentorsUseCase(this.repository);

  Future<Either<Failure, List<MentorEntity>>> call({
    String? language,
    String? specialization,
    double? minRating,
  }) async {
    return await repository.getAllMentors(
      language: language,
      specialization: specialization,
      minRating: minRating,
    );
  }
}
