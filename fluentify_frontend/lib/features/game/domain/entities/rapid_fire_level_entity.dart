import 'package:equatable/equatable.dart';
import 'rapid_fire_challenge_entity.dart';

class RapidFireLevelEntity extends Equatable {
  final int level;
  final String title;
  final List<RapidFireChallengeEntity> challenges;

  const RapidFireLevelEntity({
    required this.level,
    required this.title,
    required this.challenges,
  });

  @override
  List<Object?> get props => [level, title, challenges];
}
