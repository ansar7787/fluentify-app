import '../../domain/entities/speaking_challenge_entity.dart';

class SpeakingChallengeModel extends SpeakingChallengeEntity {
  const SpeakingChallengeModel({
    required String id,
    required String title,
    required String prompt,
    String? imageUrl,
    int durationSeconds = 60,
    String difficulty = 'Beginner',
  }) : super(
          id: id,
          title: title,
          prompt: prompt,
          imageUrl: imageUrl,
          durationSeconds: durationSeconds,
          difficulty: difficulty,
        );

  factory SpeakingChallengeModel.fromJson(Map<String, dynamic> json) {
    return SpeakingChallengeModel(
      id: json['id'],
      title: json['title'],
      prompt: json['prompt'],
      imageUrl: json['imageUrl'],
      durationSeconds: json['durationSeconds'] ?? 60,
      difficulty: json['difficulty'] ?? 'Beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'prompt': prompt,
      'imageUrl': imageUrl,
      'durationSeconds': durationSeconds,
      'difficulty': difficulty,
    };
  }
}
