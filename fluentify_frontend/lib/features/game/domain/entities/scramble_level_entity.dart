import 'package:equatable/equatable.dart';
import 'sentence_challenge_entity.dart';

class ScrambleLevelEntity extends Equatable {
  final int level;
  final String title;
  final List<SentenceChallengeEntity> challenges;

  const ScrambleLevelEntity({
    required this.level,
    required this.title,
    required this.challenges,
  });

  @override
  List<Object?> get props => [level, title, challenges];
}
