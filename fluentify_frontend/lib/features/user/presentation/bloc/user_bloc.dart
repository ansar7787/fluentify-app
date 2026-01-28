import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  UserBloc({
    required this.getUserProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(UserInitial()) {
    on<GetUserProfileEvent>((event, emit) async {
      emit(UserLoading());

      final result = await getUserProfileUseCase(NoParams());

      result.fold(
        (failure) => emit(UserError(failure.message)),
        (user) => emit(UserLoaded(user)),
      );
    });

    on<UpdateUserProfileEvent>((event, emit) async {
      // Don't emit loading here if we want to show optimistic UI or a small loader
      // For now, let's keep it simple
      final result = await updateProfileUseCase(
        fullName: event.fullName,
        avatarUrl: event.avatarUrl,
        gameLevel: event.gameLevel,
        grammarLevel: event.grammarLevel,
        speakingLevel: event.speakingLevel,
        wordMatchLevel: event.wordMatchLevel,
        typingLevel: event.typingLevel,
        dictationLevel: event.dictationLevel,
        readingLevel: event.readingLevel,
        rapidFireLevel: event.rapidFireLevel,
      );

      result.fold(
        (failure) => emit(UserError(failure.message)),
        (user) => emit(UserLoaded(user)),
      );
    });
  }
}
