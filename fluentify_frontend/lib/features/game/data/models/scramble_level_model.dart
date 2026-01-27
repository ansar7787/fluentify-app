import '../../domain/entities/scramble_level_entity.dart';
import 'sentence_challenge_model.dart';

class ScrambleLevelModel extends ScrambleLevelEntity {
  const ScrambleLevelModel({
    required super.level,
    required super.title,
    required List<SentenceChallengeModel> challenges,
  }) : super(
          challenges: challenges,
        );

  factory ScrambleLevelModel.fromJson(Map<String, dynamic> json) {
    return ScrambleLevelModel(
      level: json['level'],
      title: json['title'],
      challenges: (json['challenges'] as List)
          .map((e) => SentenceChallengeModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'title': title,
      'challenges': challenges
          .map((e) => (e as SentenceChallengeModel).toJson())
          .toList(),
    };
  }
}
