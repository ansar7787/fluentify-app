import '../../domain/entities/chat_turn_entity.dart';

class ChatTurnModel extends ChatTurnEntity {
  ChatTurnModel({
    required super.userTranscript,
    required super.response,
    super.correction,
    super.betterWay,
    required super.score,
  });

  factory ChatTurnModel.fromJson(Map<String, dynamic> json) {
    return ChatTurnModel(
      userTranscript: json['user_transcript'] ?? '',
      response: json['response'],
      correction: json['correction'],
      betterWay: json['better_way'],
      score: (json['score'] as num).toDouble(),
    );
  }
}
