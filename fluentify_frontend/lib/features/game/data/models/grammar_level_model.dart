import '../../domain/entities/grammar_level_entity.dart';
import 'grammar_challenge_model.dart';

class GrammarLevelModel extends GrammarLevelEntity {
  const GrammarLevelModel({
    required super.level,
    required super.title,
    required List<GrammarChallengeModel> challenges,
  }) : super(
          challenges: challenges,
        );

  factory GrammarLevelModel.fromJson(Map<String, dynamic> json) {
    return GrammarLevelModel(
      level: json['level'],
      title: json['title'],
      challenges: (json['challenges'] as List)
          .map((e) => GrammarChallengeModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'title': title,
      'challenges':
          challenges.map((e) => (e as GrammarChallengeModel).toJson()).toList(),
    };
  }
}
