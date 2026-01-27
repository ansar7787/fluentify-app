import 'package:equatable/equatable.dart';
import 'grammar_challenge_entity.dart';

class GrammarLevelEntity extends Equatable {
  final int level;
  final String title;
  final List<GrammarChallengeEntity> challenges;

  const GrammarLevelEntity({
    required this.level,
    required this.title,
    required this.challenges,
  });

  @override
  List<Object?> get props => [level, title, challenges];
}
