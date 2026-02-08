import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/peer_repository.dart';
import '../../../../core/constants/app_constants.dart';

class PeerRepositoryImpl implements PeerRepository {
  late io.Socket _socket;
  final _matchController = StreamController<Map<String, dynamic>>.broadcast();

  PeerRepositoryImpl() {
    _initSocket();
  }

  void _initSocket() {
    // Using AppConstants for base URL if available, else fallback
    final backendUrl =
        '${AppConstants.apiBaseUrl.replaceFirst('/api', '')}/peer';

    _socket = io.io(
      backendUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket.onConnect((_) => debugPrint('Connected to Peer Namespace'));

    _socket.on('match_found', (data) {
      _matchController.add(Map<String, dynamic>.from(data));
    });

    _socket.onDisconnect((_) => debugPrint('Disconnected from Peer Namespace'));
  }

  @override
  Stream<Map<String, dynamic>> get matchStream => _matchController.stream;

  @override
  void joinQueue(UserEntity user) {
    if (!_socket.connected) {
      _socket.connect();
    }

    _socket.emit('join_queue', {
      'userId': user.id,
      'name': user.fullName,
      'level': user.level,
    });
  }

  @override
  void leaveQueue() {
    _socket.emit('leave_queue');
  }

  @override
  void disconnect() {
    _socket.disconnect();
  }
}
