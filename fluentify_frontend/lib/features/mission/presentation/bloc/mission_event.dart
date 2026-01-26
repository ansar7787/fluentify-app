import 'package:equatable/equatable.dart';

abstract class MissionEvent extends Equatable {
  const MissionEvent();
  @override
  List<Object?> get props => [];
}

class LoadMissions extends MissionEvent {
  final String? level;
  const LoadMissions({this.level});
  @override
  List<Object?> get props => [level];
}

class SubmitMissionAttempt extends MissionEvent {
  final String missionId;
  final String audioPath;
  const SubmitMissionAttempt(
      {required this.missionId, required this.audioPath});
  @override
  List<Object?> get props => [missionId, audioPath];
}
