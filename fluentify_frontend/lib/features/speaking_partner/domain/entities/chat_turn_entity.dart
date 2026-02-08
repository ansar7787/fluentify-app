class ChatTurnEntity {
  final String userTranscript;
  final String response;
  final String? correction;
  final String? betterWay;
  final double score;

  ChatTurnEntity({
    required this.userTranscript,
    required this.response,
    this.correction,
    this.betterWay,
    required this.score,
  });
}

class ChatMessageEntity {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessageEntity({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}
