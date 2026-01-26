import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'peer_event.dart';
import 'peer_state.dart';

class PeerBloc extends Bloc<PeerEvent, PeerState> {
  late io.Socket socket;
  PeerBloc() : super(PeerInitial()) {
    on<JoinPeerQueue>(_onJoinQueue);
    on<LeavePeerQueue>(_onLeaveQueue);
    on<PeerMatchFound>(_onMatchFound);

    _initSocket();
  }

  void _initSocket() {
    // Replace with your actual backend URL (e.g., from config or constant)
    // For Android Emulator `10.0.2.2` is localhost
    const backendUrl = 'http://10.0.2.2:3000/peer';

    socket = io.io(
      backendUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect() // connects when joining queue? or init immediately?
          .build(),
    );

    socket.onConnect((_) {
      debugPrint('Connected to Peer Namespace');
    });

    socket.on('match_found', (data) {
      add(PeerMatchFound(Map<String, dynamic>.from(data)));
    });

    socket.onDisconnect((_) {
      debugPrint('Disconnected from Peer Namespace');
    });
  }

  void _onJoinQueue(JoinPeerQueue event, Emitter<PeerState> emit) {
    emit(PeerSearching());
    if (!socket.connected) {
      socket.connect();
    }

    socket.emit('join_queue', {
      'userId': event.user.id,
      'name': event.user.fullName,
      'level': event.user.level,
    });
  }

  void _onLeaveQueue(LeavePeerQueue event, Emitter<PeerState> emit) {
    socket.emit('leave_queue');
    emit(PeerInitial());
  }

  void _onMatchFound(PeerMatchFound event, Emitter<PeerState> emit) {
    final data = event.data;
    emit(PeerMatched(
      channelId: data['channelName'],
      token: data['token'],
      uid: data['uid'],
      peerName: data['peerName'],
    ));
  }

  @override
  Future<void> close() {
    socket.disconnect();
    socket.dispose();
    return super.close();
  }
}
