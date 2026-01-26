import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking_entity.dart';
import '../repositories/mentor_repository.dart';

class GetUserBookingsUseCase {
  final MentorRepository repository;

  GetUserBookingsUseCase(this.repository);

  Future<Either<Failure, List<BookingEntity>>> call() async {
    return await repository.getUserBookings();
  }
}
