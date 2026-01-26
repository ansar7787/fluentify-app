import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_stats_entity.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminStatsLoaded extends AdminState {
  final AdminStatsEntity stats;

  const AdminStatsLoaded(this.stats);

  @override
  List<Object> get props => [stats];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object> get props => [message];
}
