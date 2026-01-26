import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository repository;

  AdminBloc({required this.repository}) : super(AdminInitial()) {
    on<GetAdminStatsEvent>(_onGetStats);
  }

  Future<void> _onGetStats(
    GetAdminStatsEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result = await repository.getDashboardStats();
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (stats) => emit(AdminStatsLoaded(stats)),
    );
  }
}
