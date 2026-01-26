import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late io.Socket socket;
  bool _isConnected = false;

  void initSocket(String userId) {
    if (_isConnected) return;

    // Use loopback for emulator (10.0.2.2) or localhost for web/device
    // If backend is on 3000
    // Replace with your actual backend URL/IP
    socket = io.io('http://10.0.2.2:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'userId': userId},
    });

    socket.connect();

    socket.onConnect((_) {
      debugPrint('Socket connected');
      _isConnected = true;
    });

    socket.onDisconnect((_) {
      debugPrint('Socket disconnected');
      _isConnected = false;
    });

    socket.onError((data) => debugPrint('Socket Error: $data'));
  }

  void sendMessage(String senderId, String receiverId, String content) {
    socket.emit('sendMessage', {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
    });
  }

  void listenForMessages(Function(dynamic) callback) {
    socket.off('receiveMessage'); // Avoid duplicates
    socket.on('receiveMessage', callback);
  }

  void listenForMessageSent(Function(dynamic) callback) {
    socket.off('messageSent');
    socket.on('messageSent', callback);
  }

  void dispose() {
    socket.disconnect();
    _isConnected = false;
  }
}
