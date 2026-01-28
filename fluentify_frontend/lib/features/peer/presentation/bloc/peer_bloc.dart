import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/peer_usecases.dart';
import 'peer_event.dart';
import 'peer_state.dart';

class PeerBloc extends Bloc<PeerEvent, PeerState> {
  final JoinQueueUseCase joinQueueUseCase;
  final LeaveQueueUseCase leaveQueueUseCase;
  final GetMatchStreamUseCase getMatchStreamUseCase;
  StreamSubscription? _matchSubscription;

  PeerBloc({
    required this.joinQueueUseCase,
    required this.leaveQueueUseCase,
    required this.getMatchStreamUseCase,
  }) : super(PeerInitial()) {
    on<JoinPeerQueue>(_onJoinQueue);
    on<LeavePeerQueue>(_onLeaveQueue);
    on<PeerMatchFound>(_onMatchFound);

    _matchSubscription = getMatchStreamUseCase().listen((data) {
      add(PeerMatchFound(data));
    });
  }

  void _onJoinQueue(JoinPeerQueue event, Emitter<PeerState> emit) {
    emit(PeerSearching());
    joinQueueUseCase(event.user);
  }

  void _onLeaveQueue(LeavePeerQueue event, Emitter<PeerState> emit) {
    leaveQueueUseCase();
    emit(PeerInitial());
  }

  void _onMatchFound(PeerMatchFound event, Emitter<PeerState> emit) {
    final data = event.data;
    emit(PeerMatched(
      channelId: data['channelName'] ?? '',
      token: data['token'] ?? '',
      uid: data['uid'] ?? 0,
      peerName: data['peerName'] ?? 'Unknown',
    ));
  }

  @override
  Future<void> close() {
    _matchSubscription?.cancel();
    return super.close();
  }
}
