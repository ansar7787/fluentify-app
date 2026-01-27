import '../../domain/entities/speaking_level_entity.dart';
import 'speaking_challenge_model.dart';

class SpeakingLevelModel extends SpeakingLevelEntity {
  const SpeakingLevelModel({
    required int level,
    required String title,
    required List<SpeakingChallengeModel> challenges,
  }) : super(
          level: level,
          title: title,
          challenges: challenges,
        );

  factory SpeakingLevelModel.fromJson(Map<String, dynamic> json) {
    return SpeakingLevelModel(
      level: json['level'],
      title: json['title'],
      challenges: (json['challenges'] as List)
          .map((e) => SpeakingChallengeModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'title': title,
      'challenges': challenges
          .map((e) => (e as SpeakingChallengeModel).toJson())
          .toList(),
    };
  }
}
