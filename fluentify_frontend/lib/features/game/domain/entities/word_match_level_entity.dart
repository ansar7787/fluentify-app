import 'package:equatable/equatable.dart';
import 'word_match_challenge_entity.dart';

class WordMatchLevelEntity extends Equatable {
  final int level;
  final String title;
  final List<WordMatchChallengeEntity> challenges;

  const WordMatchLevelEntity({
    required this.level,
    required this.title,
    required this.challenges,
  });

  @override
  List<Object?> get props => [level, title, challenges];
}
