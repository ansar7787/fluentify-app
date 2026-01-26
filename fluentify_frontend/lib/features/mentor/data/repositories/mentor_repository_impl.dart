import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/mentor_entity.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/mentor_repository.dart';
import '../datasources/mentor_remote_datasource.dart';

class MentorRepositoryImpl implements MentorRepository {
  final MentorRemoteDataSource remoteDataSource;

  MentorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, MentorEntity>> createProfile({
    required String specialization,
    required List<String> languages,
    required String bio,
    required double hourlyRate,
  }) async {
    try {
      final result = await remoteDataSource.createProfile({
        'specialization': specialization,
        'languages': languages,
        'bio': bio,
        'hourlyRate': hourlyRate,
      });
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MentorEntity>>> getAllMentors({
    String? language,
    String? specialization,
    double? minRating,
  }) async {
    try {
      final filters = <String, dynamic>{};
      if (language != null) filters['language'] = language;
      if (specialization != null) filters['specialization'] = specialization;
      if (minRating != null) filters['minRating'] = minRating;

      final result = await remoteDataSource.getAllMentors(filters);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MentorEntity>> getMentorById(String id) async {
    try {
      final result = await remoteDataSource.getMentorById(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> createBooking({
    required String mentorId,
    required DateTime scheduledAt,
    required int durationMinutes,
  }) async {
    try {
      final result = await remoteDataSource.createBooking({
        'mentorId': mentorId,
        'scheduledAt': scheduledAt.toIso8601String(),
        'durationMinutes': durationMinutes,
      });
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getUserBookings() async {
    try {
      final result = await remoteDataSource.getUserBookings();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
