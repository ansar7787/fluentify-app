import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_mentors_usecase.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import 'mentor_event.dart';
import 'mentor_state.dart';

class MentorBloc extends Bloc<MentorEvent, MentorState> {
  final GetAllMentorsUseCase getAllMentorsUseCase;
  final CreateBookingUseCase createBookingUseCase;

  MentorBloc({
    required this.getAllMentorsUseCase,
    required this.createBookingUseCase,
  }) : super(MentorInitial()) {
    on<GetAllMentorsRequested>(_onGetAllMentorsRequested);
    on<CreateBookingRequested>(_onCreateBookingRequested);
  }

  Future<void> _onGetAllMentorsRequested(
    GetAllMentorsRequested event,
    Emitter<MentorState> emit,
  ) async {
    emit(MentorLoading());

    final result = await getAllMentorsUseCase(
      language: event.language,
      specialization: event.specialization,
      minRating: event.minRating,
    );

    result.fold(
      (failure) => emit(MentorError(message: failure.message)),
      (mentors) => emit(AllMentorsLoaded(mentors: mentors)),
    );
  }

  Future<void> _onCreateBookingRequested(
    CreateBookingRequested event,
    Emitter<MentorState> emit,
  ) async {
    emit(MentorLoading());

    final result = await createBookingUseCase(
      mentorId: event.mentorId,
      scheduledAt: event.scheduledAt,
      durationMinutes: event.durationMinutes,
    );

    result.fold(
      (failure) => emit(MentorError(message: failure.message)),
      (booking) => emit(BookingCreated(booking: booking)),
    );
  }
}
