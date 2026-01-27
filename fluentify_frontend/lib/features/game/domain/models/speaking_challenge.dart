import 'package:equatable/equatable.dart';

class SpeakingLevel extends Equatable {
  final int level;
  final String title;
  final List<SpeakingChallenge> challenges;

  const SpeakingLevel({
    required this.level,
    required this.title,
    required this.challenges,
  });

  @override
  List<Object?> get props => [level, title, challenges];

  static List<SpeakingLevel> getLevels() {
    return List.generate(100, (index) {
      final levelNum = index + 1;
      return SpeakingLevel(
        level: levelNum,
        title: 'Fluency Mastery $levelNum',
        challenges: _generateChallengesForLevel(levelNum),
      );
    });
  }

  static List<SpeakingChallenge> _generateChallengesForLevel(int level) {
    // Speaking missions are longer, so maybe 1-2 per level is enough for a "game" feel
    int challengeCount = 1;
    List<SpeakingChallenge> challenges = [];
    for (int i = 0; i < challengeCount; i++) {
      challenges.add(_generateProceduralChallenge(level, i));
    }
    return challenges;
  }

  static SpeakingChallenge _generateProceduralChallenge(int level, int index) {
    int seed = level * 10 + index;
    String difficulty = 'Beginner';
    if (level > 30) difficulty = 'Intermediate';
    if (level > 70) difficulty = 'Advanced';

    final prompts = [
      {
        't': 'Morning Bliss',
        'p': 'Describe your ideal breakfast and why you enjoy it.',
        'd': 30
      },
      {
        't': 'City vs Country',
        'p':
            'Which do you prefer: living in a busy city or a quiet village? Explain why.',
        'd': 45
      },
      {
        't': 'Travel Dreams',
        'p': 'If you could travel anywhere tomorrow, where would you go?',
        'd': 60
      },
      {
        't': 'Book Worm',
        'p': 'Tell me about the last book you read or movie you watched.',
        'd': 60
      },
      {
        't': 'Skill Share',
        'p':
            'Explain how to do something you are good at, like cooking or a sport.',
        'd': 90
      },
      {
        't': 'Memory Lane',
        'p': 'What is your favorite childhood memory?',
        'd': 60
      },
      {
        't': 'Future Self',
        'p': 'Where do you see yourself in five years?',
        'd': 60
      },
      {
        't': 'Global Issues',
        'p':
            'What do you think is the biggest challenge facing the world today?',
        'd': 120
      },
      {
        't': 'Invention',
        'p':
            'If you could invent something to make life easier, what would it be?',
        'd': 90
      },
    ];

    final prompt = prompts[seed % prompts.length];

    return SpeakingChallenge(
      id: 's_${level}_$index',
      title: prompt['t'] as String,
      prompt: prompt['p'] as String,
      durationSeconds: prompt['d'] as int,
      difficulty: difficulty,
    );
  }
}

class SpeakingChallenge extends Equatable {
  final String id;
  final String title;
  final String prompt;
  final String? imageUrl;
  final int durationSeconds;
  final String difficulty;

  const SpeakingChallenge({
    required this.id,
    required this.title,
    required this.prompt,
    this.imageUrl,
    this.durationSeconds = 60,
    this.difficulty = 'Beginner',
  });

  @override
  List<Object?> get props =>
      [id, title, prompt, imageUrl, durationSeconds, difficulty];
}
