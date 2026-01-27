import 'package:equatable/equatable.dart';
import 'reading_challenge_entity.dart';

class ReadingLevelEntity extends Equatable {
  final int level;
  final String title;
  final List<ReadingChallengeEntity> challenges;

  const ReadingLevelEntity({
    required this.level,
    required this.title,
    required this.challenges,
  });

  @override
  List<Object?> get props => [level, title, challenges];
}
