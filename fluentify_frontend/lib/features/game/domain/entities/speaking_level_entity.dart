import 'package:equatable/equatable.dart';
import 'speaking_challenge_entity.dart';

class SpeakingLevelEntity extends Equatable {
  final int level;
  final String title;
  final List<SpeakingChallengeEntity> challenges;

  const SpeakingLevelEntity({
    required this.level,
    required this.title,
    required this.challenges,
  });

  @override
  List<Object?> get props => [level, title, challenges];
}
