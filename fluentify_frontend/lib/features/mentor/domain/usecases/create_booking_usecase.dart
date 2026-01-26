import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking_entity.dart';
import '../repositories/mentor_repository.dart';

class CreateBookingUseCase {
  final MentorRepository repository;

  CreateBookingUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> call({
    required String mentorId,
    required DateTime scheduledAt,
    required int durationMinutes,
  }) async {
    return await repository.createBooking(
      mentorId: mentorId,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
    );
  }
}
