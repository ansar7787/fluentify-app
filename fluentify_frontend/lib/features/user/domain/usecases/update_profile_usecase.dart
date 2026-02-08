import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/user_repository.dart';

class UpdateProfileUseCase {
  final UserRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    String? fullName,
    String? avatarUrl,
    int? gameLevel,
    int? grammarLevel,
    int? speakingLevel,
    int? wordMatchLevel,
    int? typingLevel,
    int? dictationLevel,
    int? readingLevel,
    int? rapidFireLevel,
  }) async {
    return await repository.updateProfile(
      fullName: fullName,
      avatarUrl: avatarUrl,
      gameLevel: gameLevel,
      grammarLevel: grammarLevel,
      speakingLevel: speakingLevel,
      wordMatchLevel: wordMatchLevel,
      typingLevel: typingLevel,
      dictationLevel: dictationLevel,
      readingLevel: readingLevel,
      rapidFireLevel: rapidFireLevel,
    );
  }
}
