import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class PeerEvent extends Equatable {
  const PeerEvent();

  @override
  List<Object?> get props => [];
}

class JoinPeerQueue extends PeerEvent {
  final UserEntity user;

  const JoinPeerQueue(this.user);

  @override
  List<Object?> get props => [user];
}

class LeavePeerQueue extends PeerEvent {}

class PeerMatchFound extends PeerEvent {
  final Map<String, dynamic> data;

  const PeerMatchFound(this.data);

  @override
  List<Object?> get props => [data];
}
