import 'package:equatable/equatable.dart';

abstract class PeerState extends Equatable {
  const PeerState();

  @override
  List<Object?> get props => [];
}

class PeerInitial extends PeerState {}

class PeerSearching extends PeerState {}

class PeerMatched extends PeerState {
  final String channelId;
  final String token;
  final int uid;
  final String peerName;

  const PeerMatched({
    required this.channelId,
    required this.token,
    required this.uid,
    required this.peerName,
  });

  @override
  List<Object?> get props => [channelId, token, uid, peerName];
}

class PeerError extends PeerState {
  final String message;

  const PeerError(this.message);

  @override
  List<Object?> get props => [message];
}
