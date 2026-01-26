import 'package:equatable/equatable.dart';
import '../../domain/entities/mission_entity.dart';

abstract class MissionState extends Equatable {
  const MissionState();
  @override
  List<Object?> get props => [];
}

class MissionInitial extends MissionState {}

class MissionsLoading extends MissionState {}

class MissionsLoaded extends MissionState {
  final List<MissionEntity> missions;
  const MissionsLoaded(this.missions);
  @override
  List<Object?> get props => [missions];
}

class MissionSubmitting extends MissionState {}

class MissionSubmitted extends MissionState {
  final MissionSubmissionResultEntity result;
  const MissionSubmitted(this.result);
  @override
  List<Object?> get props => [result];
}

class MissionError extends MissionState {
  final String message;
  const MissionError(this.message);
  @override
  List<Object?> get props => [message];
}
