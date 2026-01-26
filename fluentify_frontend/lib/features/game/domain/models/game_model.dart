import 'package:equatable/equatable.dart';

class SentenceChallenge extends Equatable {
  final String id;
  final String correctSentence;
  final List<String> shuffledWords;
  final String hint;
  final String difficulty; // Beginner, Intermediate, Expert

  const SentenceChallenge({
    required this.id,
    required this.correctSentence,
    required this.shuffledWords,
    required this.hint,
    this.difficulty = 'Beginner',
  });

  @override
  List<Object?> get props =>
      [id, correctSentence, shuffledWords, hint, difficulty];

  factory SentenceChallenge.create({
    required String id,
    required String sentence,
    required String hint,
    String difficulty = 'Beginner',
  }) {
    final words = sentence.split(' ')..shuffle();
    return SentenceChallenge(
      id: id,
      correctSentence: sentence,
      shuffledWords: words,
      hint: hint,
      difficulty: difficulty,
    );
  }
}

class GameLevel extends Equatable {
  final int level;
  final String title;
  final List<SentenceChallenge> challenges;
  final bool isLocked;

  const GameLevel({
    required this.level,
    required this.title,
    required this.challenges,
    this.isLocked = true,
  });

  @override
  List<Object?> get props => [level, title, challenges, isLocked];

  GameLevel copyWith({
    int? level,
    String? title,
    List<SentenceChallenge>? challenges,
    bool? isLocked,
  }) {
    return GameLevel(
      level: level ?? this.level,
      title: title ?? this.title,
      challenges: challenges ?? this.challenges,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  static List<GameLevel> getLevels() {
    return List.generate(100, (index) {
      final levelNum = index + 1;
      return GameLevel(
        level: levelNum,
        title: 'Level $levelNum',
        isLocked: index != 0, // First level is unlocked by default
        challenges: _generateChallengesForLevel(levelNum),
      );
    });
  }

  static List<SentenceChallenge> _generateChallengesForLevel(int level) {
    String difficulty = 'Beginner';
    if (level > 20) difficulty = 'Intermediate';
    if (level > 50) difficulty = 'Expert';

    List<SentenceChallenge> challenges = [];
    int challengeCount = 3 + (level ~/ 10).clamp(0, 5);

    // Use a large multiplier to ensure seeds don't overlap between levels
    int levelSeedBase = level * 1000;

    for (int i = 0; i < challengeCount; i++) {
      challenges.add(_generateProceduralChallenge(
          levelSeedBase + i, difficulty, level, i));
    }

    return challenges;
  }

  static SentenceChallenge _generateProceduralChallenge(
      int seed, String difficulty, int level, int index) {
    // Basic Word Banks
    final subjects = [
      'I',
      'You',
      'He',
      'She',
      'We',
      'They',
      'The dog',
      'My friend',
      'The teacher',
      'A student'
    ];
    final verbsTransitive = [
      'eat',
      'drink',
      'read',
      'write',
      'buy',
      'sell',
      'watch',
      'find',
      'make',
      'take'
    ];
    final verbsIntransitive = [
      'sleep',
      'run',
      'walk',
      'sit',
      'stand',
      'work',
      'play',
      'smile',
      'laugh',
      'wait'
    ];
    final objects = [
      'an apple',
      'a book',
      'water',
      'pizza',
      'the car',
      'a movie',
      'music',
      'a letter',
      'coffee',
      'tea'
    ];
    final adjectives = [
      'happy',
      'sad',
      'fast',
      'slow',
      'big',
      'small',
      'hot',
      'cold',
      'good',
      'bad',
      'tired',
      'busy'
    ];
    final places = [
      'at home',
      'in the park',
      'at school',
      'in the office',
      'at the store',
      'near the bank',
      'on the street'
    ];
    final times = [
      'today',
      'now',
      'later',
      'tomorrow',
      'yesterday',
      'tonight',
      'in the morning',
      'at night'
    ];
    final adverbs = [
      'quickly',
      'slowly',
      'happily',
      'sadly',
      'often',
      'never',
      'always',
      'sometimes'
    ];

    // Complex Word Banks
    final abstractNouns = [
      'Freedom',
      'Success',
      'Honesty',
      'Creativity',
      'Technology',
      'Education',
      'Nature',
      'Justice'
    ];
    final complexVerbs = [
      'requires',
      'provides',
      'creates',
      'improves',
      'destroys',
      'enhances',
      'demands',
      'suggests'
    ];
    final connectors = [
      'because',
      'although',
      'if',
      'when',
      'while',
      'before',
      'after',
      'unless'
    ];

    String sentence = '';
    String hint = '';

    // Deterministic Random helper
    int getRandom(int max, int salt) => (seed + salt) % max;
    T getItem<T>(List<T> list, int salt) => list[getRandom(list.length, salt)];

    // Determine precise difficulty tier based on level
    String tier = 'Intro';
    if (level > 5) tier = 'Beginner';
    if (level > 20) tier = 'Intermediate';
    if (level > 45) tier = 'Advanced';
    if (level > 75) tier = 'Expert';

    // tier is used below for logic logic checks

    if (tier == 'Intro') {
      // Levels 1-5: Strictly 3 words, very simple SVO
      // [Subject] [Verb] [Object] or [Subject] is [Adjective]
      int template = getRandom(2, 0);
      if (template == 0) {
        String s = getItem(subjects, 1);
        String v = getItem(verbsTransitive, 2);
        String o = getItem(objects, 3);
        // Force simple objects only (remove "an", "the", "a" for absolute simplicity if needed,
        // but current list has articles like "an apple". Let's accept that.)
        sentence = '$s $v $o';
        hint = 'Simple action: Who does what?';
      } else {
        String s = getItem(subjects, 4);
        String a = getItem(adjectives, 5);
        sentence = '$s is $a';
        hint = 'Simple description.';
      }
    } else if (tier == 'Beginner') {
      // Levels 6-20: 3-5 words
      // Templates: SVO, S-is-A, SV-Place
      int template = getRandom(3, 0);
      if (template == 0) {
        String s = getItem(subjects, 1);
        String v = getItem(verbsTransitive, 2);
        String o = getItem(objects, 3);
        sentence = '$s $v $o';
        hint = 'Identify the action.';
      } else if (template == 1) {
        String s = getItem(subjects, 6);
        String v = getItem(verbsIntransitive, 7);
        String p = getItem(places, 8);
        sentence = '$s $v $p';
        hint = 'Where did it happen?';
      } else {
        String s = getItem(subjects, 4);
        String v = getItem(verbsIntransitive, 9);
        String a = getItem(adverbs, 10);
        sentence = '$s $v $a';
        hint = 'How was the action done?';
      }
    } else if (tier == 'Intermediate') {
      // Levels 21-45: 5-7 words, adding Time, Adverbs, and longer phrases
      // Templates: Time-SVO, SVO-Place, S-Adv-V-O
      int template = getRandom(3, 10);
      if (template == 0) {
        String t = getItem(times, 11);
        String s = getItem(subjects, 12);
        String v = getItem(verbsTransitive, 13);
        String o = getItem(objects, 14);
        sentence = '$t $s $v $o';
        hint = 'Start with the time.';
      } else if (template == 1) {
        String s = getItem(subjects, 15);
        String v = getItem(verbsTransitive, 16);
        String o = getItem(objects, 17);
        String p = getItem(places, 18);
        sentence = '$s $v $o $p';
        hint = 'Action + Object + Location.';
      } else {
        String s = getItem(subjects, 19);
        String adv = getItem(adverbs, 20);
        String v = getItem(verbsTransitive, 21);
        String o = getItem(objects, 22);
        sentence = '$s $adv $v $o';
        hint = 'Who, How, Action, What?';
      }
    } else if (tier == 'Advanced') {
      // Levels 46-75: Complex structures, 7-9 words
      // Templates: Connector-Clause, Compound sentences
      int template = getRandom(3, 30);
      if (template == 0) {
        // [Connector] [S] [V], [S] [V] [O]
        String c = getItem(connectors, 34);
        String s1 = getItem(subjects, 35);
        String v1 = getItem(verbsIntransitive, 36);
        String s2 = getItem(subjects, 37);
        String v2 = getItem(verbsTransitive, 38);
        String o2 = getItem(objects, 39);
        sentence = '$c $s1 $v1, $s2 $v2 $o2';
        hint = 'Cause and effect logic.';
      } else if (template == 1) {
        // [S] [V] [O] [Connector] [S] is [Adj]
        String s1 = getItem(subjects, 40);
        String v1 = getItem(verbsTransitive, 41);
        String o1 = getItem(objects, 42);
        String c = getItem(connectors, 43);
        String s2 = getItem(subjects, 44);
        String a = getItem(adjectives, 45);
        sentence = '$s1 $v1 $o1 $c $s2 is $a';
        hint = 'Link two related ideas.';
      } else {
        // [Abstract] [ComplexVerb] [Abstract] [Place]
        String s = getItem(abstractNouns, 46);
        String v = getItem(complexVerbs, 47);
        String o = getItem(abstractNouns, 48);
        String p = getItem(places, 49);
        sentence =
            '$s $v $o $p'; // e.g., "Creativity requires Freedom in the office"
        hint = 'Abstract concepts in context.';
      }
    } else {
      // Expert (Levels 76-100): Challenging, Abstract, Max length
      int template = getRandom(3, 60);
      if (template == 0) {
        // Quote-like structure
        // [Abstract] is [Adj] [Connector] [Abstract] [ComplexVerb] [Abstract]
        String s1 = getItem(abstractNouns, 50);
        String a = getItem(adjectives, 51);
        String c = getItem(connectors, 52);
        String s2 = getItem(abstractNouns, 53);
        String v = getItem(complexVerbs, 54);
        String o = getItem(abstractNouns, 55);
        sentence = '$s1 is $a $c $s2 $v $o';
        hint = 'A complex philosophical statement.';
      } else if (template == 1) {
        // Double Time/Condition
        // [Time], [Connector] [S] [V] [O], [S] [V]
        String t = getItem(times, 60);
        String c = getItem(connectors, 61);
        String s1 = getItem(subjects, 62);
        String v1 = getItem(verbsTransitive, 63);
        String o1 = getItem(objects, 64);
        String s2 = getItem(subjects, 65);
        String v2 = getItem(verbsIntransitive, 66);
        sentence = '$t, $c $s1 $v1 $o1, $s2 $v2';
        hint = 'Time, Logic, Action, Consequence.';
      } else {
        // The Pangram-style long sentence
        String s = getItem(subjects, 70);
        String adv = getItem(adverbs, 71);
        String v = getItem(verbsTransitive, 72);
        String o = getItem(objects, 73);
        String c = getItem(connectors, 74);
        String s2 = getItem(abstractNouns, 75);
        String v2 = getItem(complexVerbs, 76);
        String o2 = getItem(abstractNouns, 77);
        sentence = '$s $adv $v $o $c $s2 $v2 $o2';
        hint = 'Combine daily life with abstract thought.';
      }
    }

    // Capitalize first letter
    sentence = sentence[0].toUpperCase() + sentence.substring(1);

    // ID must be unique
    return SentenceChallenge.create(
      id: 'level_${level}_challenge_$index',
      sentence: sentence,
      hint: hint,
      difficulty: difficulty,
    );
  }
}
