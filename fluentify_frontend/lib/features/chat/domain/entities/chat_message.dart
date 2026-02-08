import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final String roomId;
  final DateTime timestamp;
  final bool isMe;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.roomId,
    required this.timestamp,
    this.isMe = false,
  });

  @override
  List<Object?> get props =>
      [id, content, senderId, senderName, roomId, timestamp, isMe];
}
