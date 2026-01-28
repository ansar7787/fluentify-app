import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/usecases/get_sessions_usecase.dart';

// Events
abstract class SessionEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadSessions extends SessionEvent {}

// States
abstract class SessionState extends Equatable {
  @override
  List<Object> get props => [];
}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionLoaded extends SessionState {
  final List<SessionEntity> sessions;
  SessionLoaded(this.sessions);
}

class SessionError extends SessionState {
  final String message;
  SessionError(this.message);
}

// Bloc
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final GetSessionsUseCase getSessions;

  SessionBloc({required this.getSessions}) : super(SessionInitial()) {
    on<LoadSessions>((event, emit) async {
      emit(SessionLoading());
      try {
        final sessions = await getSessions();
        emit(SessionLoaded(sessions));
      } catch (e) {
        emit(SessionError(e.toString()));
      }
    });
  }
}
