import 'package:equatable/equatable.dart';
import 'dictation_challenge_entity.dart';

class DictationLevelEntity extends Equatable {
  final int level;
  final String title;
  final List<DictationChallengeEntity> challenges;

  const DictationLevelEntity({
    required this.level,
    required this.title,
    required this.challenges,
  });

  @override
  List<Object?> get props => [level, title, challenges];
}
