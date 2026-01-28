import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.senderId,
    required super.senderName,
    required super.roomId,
    required super.timestamp,
    super.isMe,
  });

  factory ChatMessageModel.fromJson(
      Map<String, dynamic> json, String currentUserId) {
    return ChatMessageModel(
      id: json['id'] ?? const Uuid().v4(),
      content: json['message'] ?? '',
      senderId: json['senderId'] ?? 'unknown',
      senderName: json['sender'] ?? 'Unknown',
      roomId: json['room'] ?? 'global',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      isMe: (json['sender'] == currentUserId) ||
          (json['senderId'] == currentUserId),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': content,
      'senderId': senderId,
      'sender': senderName,
      'room': roomId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
