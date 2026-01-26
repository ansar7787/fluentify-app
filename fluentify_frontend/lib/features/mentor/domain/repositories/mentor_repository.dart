import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/mentor_entity.dart';
import '../entities/booking_entity.dart';

abstract class MentorRepository {
  Future<Either<Failure, MentorEntity>> createProfile({
    required String specialization,
    required List<String> languages,
    required String bio,
    required double hourlyRate,
  });

  Future<Either<Failure, List<MentorEntity>>> getAllMentors({
    String? language,
    String? specialization,
    double? minRating,
  });

  Future<Either<Failure, MentorEntity>> getMentorById(String id);

  Future<Either<Failure, BookingEntity>> createBooking({
    required String mentorId,
    required DateTime scheduledAt,
    required int durationMinutes,
  });

  Future<Either<Failure, List<BookingEntity>>> getUserBookings();
}
