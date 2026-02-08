import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/app_constants.dart';

class ChatService {
  late io.Socket _socket;

  // Initialize Socket
  void initSocket() {
    _socket = io.io(AppConstants.apiBaseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket.connect();

    _socket.onConnect((_) {
      debugPrint('Connected to Socket');
    });

    _socket.onDisconnect((_) {
      debugPrint('Disconnected from Socket');
    });
  }

  // Join Room
  void joinRoom(String room) {
    _socket.emit('joinRoom', room);
  }

  // Send Message
  void sendMessage(String room, String message, String sender) {
    _socket.emit('sendMessage', {
      'room': room,
      'message': message,
      'sender': sender,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Listen for Messages
  void onMessageReceived(Function(dynamic) callback) {
    _socket.on('receiveMessage', (data) {
      callback(data);
    });
  }

  void disconnect() {
    _socket.disconnect();
  }
}
