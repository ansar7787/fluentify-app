import 'package:equatable/equatable.dart';
import 'typing_challenge_entity.dart';

class TypingLevelEntity extends Equatable {
  final int level;
  final String title;
  final List<TypingChallengeEntity> challenges;

  const TypingLevelEntity({
    required this.level,
    required this.title,
    required this.challenges,
  });

  @override
  List<Object?> get props => [level, title, challenges];
}
