import 'package:equatable/equatable.dart';
import '../../domain/entities/mentor_entity.dart';
import '../../domain/entities/booking_entity.dart';

abstract class MentorState extends Equatable {
  const MentorState();

  @override
  List<Object?> get props => [];
}

class MentorInitial extends MentorState {}

class MentorLoading extends MentorState {}

class AllMentorsLoaded extends MentorState {
  final List<MentorEntity> mentors;

  const AllMentorsLoaded({required this.mentors});

  @override
  List<Object?> get props => [mentors];
}

class BookingCreated extends MentorState {
  final BookingEntity booking;

  const BookingCreated({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class MentorError extends MentorState {
  final String message;

  const MentorError({required this.message});

  @override
  List<Object?> get props => [message];
}
