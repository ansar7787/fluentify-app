import 'package:equatable/equatable.dart';

class GrammarLevel extends Equatable {
  final int level;
  final String title;
  final List<GrammarChallenge> challenges;

  const GrammarLevel({
    required this.level,
    required this.title,
    required this.challenges,
  });

  @override
  List<Object?> get props => [level, title, challenges];

  static List<GrammarLevel> getLevels() {
    return List.generate(100, (index) {
      final levelNum = index + 1;
      return GrammarLevel(
        level: levelNum,
        title: 'Grammar Master $levelNum',
        challenges: _generateChallengesForLevel(levelNum),
      );
    });
  }

  static List<GrammarChallenge> _generateChallengesForLevel(int level) {
    int challengeCount = 5;
    List<GrammarChallenge> challenges = [];
    for (int i = 0; i < challengeCount; i++) {
      challenges.add(_generateProceduralChallenge(level, i));
    }
    return challenges;
  }

  static GrammarChallenge _generateProceduralChallenge(int level, int index) {
    // Seed-based random
    int seed = level * 100 + index;

    // Tiers
    String difficulty = 'Beginner';
    if (level > 33) difficulty = 'Intermediate';
    if (level > 66) difficulty = 'Advanced';

    final beginnerTemplates = [
      {
        'q': 'She ___ to school every day.',
        'o': ['go', 'goes', 'going', 'gone'],
        'a': 1,
        'e': 'Third person singular "She" take "goes".'
      },
      {
        'q': 'Look! The baby ___.',
        'o': ['sleep', 'sleeps', 'is sleeping', 'sleeping'],
        'a': 2,
        'e': 'Use present continuous for actions happening now.'
      },
      {
        'q': 'I ___ my homework yesterday.',
        'o': ['do', 'did', 'done', 'doing'],
        'a': 1,
        'e': 'Use past simple for completed actions in the past.'
      },
      {
        'q': 'There are ___ apples on the table.',
        'o': ['a', 'an', 'some', 'much'],
        'a': 2,
        'e': 'Use "some" for plural countable nouns in positive sentences.'
      },
      {
        'q': 'He ___ like coffee.',
        'o': ['don\'t', 'doesn\'t', 'do not', 'isn\'t'],
        'a': 1,
        'e': 'Third person singular negative uses "doesn\'t".'
      },
      {
        'q': 'We ___ to the cinema last night.',
        'o': ['go', 'went', 'gone', 'goes'],
        'a': 1,
        'e': 'Past simple of "go" is "went".'
      },
      {
        'q': '___ you see that bird?',
        'o': ['Do', 'Does', 'Are', 'Is'],
        'a': 0,
        'e': 'Use "Do" for second person questions.'
      },
      {
        'q': 'My brother ___ a new car.',
        'o': ['have', 'has', 'haves', 'having'],
        'a': 1,
        'e': 'Third person singular uses "has".'
      }
    ];

    final intermediateTemplates = [
      {
        'q': 'I wish I ___ more time to travel.',
        'o': ['have', 'had', 'has', 'having'],
        'a': 1,
        'e':
            'After "wish", use past simple to talk about things we want to be different in the present.'
      },
      {
        'q': 'He denied ___ the money.',
        'o': ['to steal', 'steal', 'stealing', 'stolen'],
        'a': 2,
        'e': 'The verb "deny" is followed by the -ing form (gerund).'
      },
      {
        'q': 'If I were you, I ___ that car.',
        'o': ['buy', 'will buy', 'would buy', 'bought'],
        'a': 2,
        'e': 'Second conditional: "If" + past simple, "would" + infinitive.'
      },
      {
        'q': 'The cake ___ by my mother yesterday.',
        'o': ['baked', 'was baked', 'was baking', 'is baked'],
        'a': 1,
        'e': 'Passive voice: "was" + past participle.'
      },
      {
        'q': 'I have been living here ___ five years.',
        'o': ['since', 'for', 'during', 'while'],
        'a': 1,
        'e': 'Use "for" to talk about a period of time.'
      },
      {
        'q': 'She is much taller ___ her sister.',
        'o': ['then', 'as', 'that', 'than'],
        'a': 3,
        'e': 'Use "than" for comparisons.'
      },
      {
        'q': 'I ___ my keys. Have you seen them?',
        'o': ['lose', 'lost', 'have lost', 'was losing'],
        'a': 2,
        'e': 'Use present perfect for recent actions with present results.'
      },
      {
        'q': 'By the time we arrived, the movie ___.',
        'o': ['starts', 'started', 'had started', 'has started'],
        'a': 2,
        'e':
            'Use past perfect for an action completed before another past action.'
      }
    ];

    final advancedTemplates = [
      {
        'q': 'Seldom ___ such a beautiful sunset.',
        'o': ['I have seen', 'have I seen', 'I saw', 'did I see'],
        'a': 1,
        'e':
            'Negative adverbs like "seldom" at the start of a sentence cause inversion.'
      },
      {
        'q': 'It is essential that he ___ here on time.',
        'o': ['is', 'be', 'was', 'being'],
        'a': 1,
        'e': 'The subjunctive mood is used after adjectives like "essential".'
      },
      {
        'q': 'Were it not for your help, I ___ failed.',
        'o': ['will have', 'would have', 'had', 'must have'],
        'a': 1,
        'e': 'Inverted third conditional structure.'
      },
      {
        'q': 'No sooner ___ arrived than it started to rain.',
        'o': ['I had', 'had I', 'I have', 'have I'],
        'a': 1,
        'e': 'Inversion after "no sooner".'
      },
      {
        'q': 'He speaks as if he ___ an expert.',
        'o': ['is', 'was', 'were', 'be'],
        'a': 2,
        'e': 'Use "were" in unreal comparisons with "as if".'
      },
      {
        'q': 'Should you ___ any help, just ask.',
        'o': ['need', 'needed', 'needs', 'needing'],
        'a': 0,
        'e': 'Inverted first conditional.'
      },
      {
        'q': 'Hardly ___ the door when I heard a scream.',
        'o': ['I had opened', 'had I opened', 'I opened', 'did I open'],
        'a': 1,
        'e': 'Another example of inversion with negative adverbs.'
      },
      {
        'q': 'I would rather you ___ smoker.',
        'o': ['don\'t', 'doesn\'t', 'weren\'t', 'not be'],
        'a': 2,
        'e':
            'Use past simple after "would rather" when referring to another person.'
      }
    ];

    List<Map<String, dynamic>> selectedTemplates;
    if (difficulty == 'Beginner') {
      selectedTemplates = beginnerTemplates;
    } else if (difficulty == 'Intermediate') {
      selectedTemplates = intermediateTemplates;
    } else {
      selectedTemplates = advancedTemplates;
    }

    // Advanced selection logic to avoid immediate repeats in the same level
    // Since we have 8 templates per category and 5 questions per level, we can ensure unique
    // questions if we use a simple offset.
    int templateIndex = (seed) % selectedTemplates.length;
    final template = selectedTemplates[templateIndex];

    return GrammarChallenge(
      id: 'g_${level}_$index',
      question: template['q'],
      options: List<String>.from(template['o']),
      correctOptionIndex: template['a'],
      explanation: template['e'],
      difficulty: difficulty,
    );
  }
}

class GrammarChallenge extends Equatable {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final String difficulty;

  const GrammarChallenge({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    this.difficulty = 'Beginner',
  });

  @override
  List<Object?> get props =>
      [id, question, options, correctOptionIndex, explanation, difficulty];
}
