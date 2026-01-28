import '../../domain/entities/grammar_level_entity.dart';
import '../../domain/entities/speaking_level_entity.dart';
import '../../domain/entities/scramble_level_entity.dart';

import '../models/grammar_level_model.dart';
import '../models/grammar_challenge_model.dart';
import '../models/speaking_level_model.dart';
import '../models/speaking_challenge_model.dart';
import '../models/scramble_level_model.dart';
import '../models/sentence_challenge_model.dart';
import '../../domain/entities/word_match_level_entity.dart';
import '../../domain/entities/typing_level_entity.dart';
import '../../domain/entities/dictation_level_entity.dart';
import '../../domain/entities/reading_level_entity.dart';
import '../../domain/entities/rapid_fire_level_entity.dart';
import '../models/word_match_models.dart';
import '../models/typing_models.dart';
import '../models/dictation_models.dart';
import '../models/reading_models.dart';
import '../models/rapid_fire_models.dart';

abstract class GameLocalDataSource {
  Future<List<GrammarLevelEntity>> getGrammarLevels();
  Future<List<SpeakingLevelEntity>> getSpeakingLevels();
  Future<List<ScrambleLevelEntity>> getScrambleLevels();
  Future<List<WordMatchLevelEntity>> getWordMatchLevels();
  Future<List<TypingLevelEntity>> getTypingLevels();
  Future<List<DictationLevelEntity>> getDictationLevels();
  Future<List<ReadingLevelEntity>> getReadingLevels();
  Future<List<RapidFireLevelEntity>> getRapidFireLevels();
}

class GameLocalDataSourceImpl implements GameLocalDataSource {
  @override
  Future<List<GrammarLevelModel>> getGrammarLevels() async {
    return List.generate(100, (index) {
      final levelNum = index + 1;
      String tier = 'Beginner';
      if (levelNum > 33) tier = 'Intermediate';
      if (levelNum > 66) tier = 'Advanced';

      final names = {
        'Beginner': [
          'Noun Explorer',
          'Verb Venture',
          'Pronoun Path',
          'Article Avenue',
          'Tense Traveler',
          'Sentence Starter',
          'Grammar Guard',
          'Word Wizard',
          'Basic Builder',
          'Punctuation Pilot'
        ],
        'Intermediate': [
          'Clause Captain',
          'Idiom Idol',
          'Phrasal Fanatic',
          'Passive Pro',
          'Modal Master',
          'Conditional Champ',
          'Gerund Genius',
          'Infinitive Iceman',
          'Aspect Ace',
          'Conjunction Commander'
        ],
        'Advanced': [
          'Subjunctive Sage',
          'Inversion Expert',
          'Syntax Sorcerer',
          'Lexical Legend',
          'Rhetoric Ruler',
          'Dialect Dean',
          'Etymology Elite',
          'Linguistics Lord',
          'Academic Architect',
          'Fluency Founder'
        ]
      };

      final tierNames = names[tier]!;
      final title = '${tierNames[index % tierNames.length]} $levelNum';

      return GrammarLevelModel(
        level: levelNum,
        title: title,
        challenges: _generateGrammarChallenges(levelNum),
      );
    });
  }

  List<GrammarChallengeModel> _generateGrammarChallenges(int level) {
    int challengeCount = 5;
    List<GrammarChallengeModel> challenges = [];
    for (int i = 0; i < challengeCount; i++) {
      challenges.add(_generateProceduralGrammarChallenge(level, i));
    }
    return challenges;
  }

  GrammarChallengeModel _generateProceduralGrammarChallenge(
      int level, int index) {
    int seed = level * 100 + index;
    String difficulty = 'Beginner';
    if (level > 33) difficulty = 'Intermediate';
    if (level > 66) difficulty = 'Advanced';

    final beginnerTemplates = [
      {
        'q': 'She ___ to school every day.',
        'o': ['go', 'goes', 'going', 'gone'],
        'a': 1,
        'e': '3rd person singular "She" takes "goes".'
      },
      {
        'q': 'Look! The baby ___.',
        'o': ['sleep', 'sleeps', 'is sleeping', 'sleeping'],
        'a': 2,
        'e': 'Present continuous for actions in progress.'
      },
      {
        'q': 'I ___ my homework yesterday.',
        'o': ['do', 'did', 'done', 'doing'],
        'a': 1,
        'e': 'Past simple for finished past actions.'
      },
      {
        'q': 'There are ___ apples on the table.',
        'o': ['a', 'an', 'some', 'much'],
        'a': 2,
        'e': 'Use "some" for plural countable nouns.'
      },
      {
        'q': 'He ___ like coffee.',
        'o': ['don\'t', 'doesn\'t', 'do not', 'isn\'t'],
        'a': 1,
        'e': 'Negative singular uses "doesn\'t".'
      },
      {
        'q': '___ you like pizza?',
        'o': ['Do', 'Does', 'Is', 'Are'],
        'a': 0,
        'e': 'Direct question for "you" uses "Do".'
      },
      {
        'q': 'My cat ___ sleeping right now.',
        'o': ['is', 'are', 'am', 'be'],
        'a': 0,
        'e': 'Singular subject "cat" takes "is".'
      },
      {
        'q': 'I have two ___.',
        'o': ['dog', 'dogs', 'doges', 'dog\'s'],
        'a': 1,
        'e': 'Plural of "dog" is "dogs".'
      },
      {
        'q': 'This is ___ apple.',
        'o': ['a', 'an', 'the', 'some'],
        'a': 1,
        'e': 'Use "an" before vowel sounds.'
      },
      {
        'q': 'We ___ at the park yesterday.',
        'o': ['was', 'were', 'am', 'been'],
        'a': 1,
        'e': 'Plural past of "be" is "were".'
      },
      {
        'q': 'Listen! The birds ___.',
        'o': ['sing', 'sings', 'are singing', 'singing'],
        'a': 2,
        'e': 'Progressive action happening now.'
      },
      {
        'q': 'He ___ his car every Sunday.',
        'o': ['wash', 'washes', 'washing', 'washed'],
        'a': 1,
        'e': 'Routine action with 3rd person singular.'
      },
      {
        'q': 'I don\'t have ___ money.',
        'o': ['some', 'any', 'many', 'a'],
        'a': 1,
        'e': 'Use "any" in negative sentences.'
      },
      {
        'q': '___ is your favorite color?',
        'o': ['What', 'Which', 'Who', 'Where'],
        'a': 0,
        'e': '"What" for general choices.'
      },
      {
        'q': 'They ___ to the cinema last week.',
        'o': ['go', 'goes', 'went', 'gone'],
        'a': 2,
        'e': 'Past of "go" is "went".'
      },
    ];

    final intermediateTemplates = [
      {
        'q': 'I wish I ___ more time.',
        'o': ['have', 'had', 'has', 'having'],
        'a': 1,
        'e': 'Hypothetical present uses past simple.'
      },
      {
        'q': 'He denied ___ the vase.',
        'o': ['breaking', 'to break', 'break', 'broken'],
        'a': 0,
        'e': '"Deny" is followed by a gerund.'
      },
      {
        'q': 'If I ___ you, I would go.',
        'o': ['am', 'was', 'were', 'be'],
        'a': 2,
        'e': '2nd conditional uses "were" for all subjects.'
      },
      {
        'q': 'The book ___ by him.',
        'o': ['wrote', 'was written', 'was writing', 'is writing'],
        'a': 1,
        'e': 'Passive voice structure.'
      },
      {
        'q': 'I have been here ___ 2010.',
        'o': ['for', 'since', 'during', 'from'],
        'a': 1,
        'e': '"Since" for a specific point in time.'
      },
      {
        'q': 'You ___ to see a doctor.',
        'o': ['should', 'ought', 'must', 'better'],
        'a': 1,
        'e': '"Ought" must be followed by "to".'
      },
      {
        'q': 'I\'m not used to ___ early.',
        'o': ['wake up', 'waking up', 'woken up', 'woke up'],
        'a': 1,
        'e': '"Be used to" takes the -ing form.'
      },
      {
        'q': 'She ___ have seen him yesterday.',
        'o': ['must', 'can', 'ought', 'should'],
        'a': 0,
        'e': 'Logical deduction about the past.'
      },
      {
        'q': 'By next year, I ___ graduated.',
        'o': ['will', 'will have', 'am', 'have'],
        'a': 1,
        'e': 'Future perfect for completed future actions.'
      },
      {
        'q': 'Hardly ___ started when it rained.',
        'o': ['we had', 'had we', 'we', 'did we'],
        'a': 1,
        'e': 'Inversion after "Hardly".'
      },
      {
        'q': 'He is the man ___ I met.',
        'o': ['who', 'which', 'whose', 'whom'],
        'a': 3,
        'e': '"Whom" as the object of the verb.'
      },
      {
        'q': 'I\'d rather you ___ here.',
        'o': ['stay', 'stayed', 'staying', 'to stay'],
        'a': 1,
        'e': '"Would rather" someone else + past simple.'
      },
      {
        'q': 'Despite ___ tired, he worked.',
        'o': ['being', 'he was', 'be', 'of'],
        'a': 0,
        'e': '"Despite" is followed by -ing or a noun.'
      },
      {
        'q': 'I suggest that he ___ soon.',
        'o': ['leaves', 'leave', 'left', 'leaving'],
        'a': 1,
        'e': 'Subjunctive mood after "suggest".'
      },
    ];

    final advancedTemplates = [
      {
        'q': 'Seldom ___ such beauty.',
        'o': ['I see', 'see I', 'have I seen', 'I have seen'],
        'a': 2,
        'e': 'Inversion for frequency adverbs.'
      },
      {
        'q': 'It is vital that she ___ notified.',
        'o': ['is', 'be', 'was', 'being'],
        'a': 1,
        'e': 'Subjunctive for importance.'
      },
      {
        'q': 'Were it not for you, I ___ lost.',
        'o': ['am', 'would be', 'will be', 'had been'],
        'a': 1,
        'e': 'Hypothetical with "Were it not for".'
      },
      {
        'q': 'No sooner ___ gone than he arrived.',
        'o': ['she had', 'had she', 'she', 'has she'],
        'a': 1,
        'e': 'Inversion after "No sooner".'
      },
      {
        'q': 'Suppose you ___ a million dollars.',
        'o': ['win', 'won', 'have won', 'winning'],
        'a': 1,
        'e': 'Hypothetical with "Suppose".'
      },
      {
        'q': 'Should you ___ him, tell him.',
        'o': ['meet', 'met', 'meets', 'meeting'],
        'a': 0,
        'e': 'Inverted conditional for "If you should".'
      },
      {
        'q': 'He acted as though he ___ king.',
        'o': ['is', 'was', 'were', 'be'],
        'a': 2,
        'e': 'Unreal comparison uses "were".'
      },
      {
        'q': 'Little ___ know about the trap.',
        'o': ['did they', 'they did', 'do they', 'they do'],
        'a': 0,
        'e': 'Inversion for negative meaning.'
      },
      {
        'q': 'Provided that he ___, we will go.',
        'o': ['come', 'comes', 'came', 'coming'],
        'a': 1,
        'e': 'Condition with "Provided that".'
      },
      {
        'q': 'I was on the point ___ leaving.',
        'o': ['to', 'of', 'for', 'at'],
        'a': 1,
        'e': 'Collocation: "on the point of doing".'
      },
      {
        'q': 'Lest he ___ forget, remind him.',
        'o': ['should', 'will', 'might', 'must'],
        'a': 0,
        'e': '"Lest" often takes "should" or subjunctive.'
      },
      {
        'q': 'Try ___ he might, he failed.',
        'o': ['as', 'though', 'if', 'that'],
        'a': 0,
        'e': 'Concession structure "Adjective/Verb + as + subject".'
      },
    ];

    List<Map<String, dynamic>> selectedTemplates;
    if (difficulty == 'Beginner') {
      selectedTemplates = beginnerTemplates;
    } else if (difficulty == 'Intermediate') {
      selectedTemplates = intermediateTemplates;
    } else {
      selectedTemplates = advancedTemplates;
    }

    int templateIndex = (seed) % selectedTemplates.length;
    final template = selectedTemplates[templateIndex];

    return GrammarChallengeModel(
      id: 'g_${level}_$index',
      question: template['q'] as String,
      options: List<String>.from(template['o'] as List),
      correctOptionIndex: template['a'] as int,
      explanation: template['e'] as String,
      difficulty: difficulty,
    );
  }

  @override
  Future<List<SpeakingLevelModel>> getSpeakingLevels() async {
    return List.generate(100, (index) {
      final levelNum = index + 1;
      String tier = 'Beginner';
      if (levelNum > 33) tier = 'Intermediate';
      if (levelNum > 66) tier = 'Advanced';

      final names = {
        'Beginner': [
          'Ice Breaker',
          'Daily Dialog',
          'Self Talk',
          'Home Harmony',
          'Grocery Guru',
          'Friendly Flutter',
          'Intro Expert',
          'Basic Broadcaster'
        ],
        'Intermediate': [
          'Skill Scout',
          'Travel Teller',
          'Story Streamer',
          'Opinion Oasis',
          'Debate Disc',
          'Career Coach',
          'Culture Catalyst',
          'Advice Anchor'
        ],
        'Advanced': [
          'Philosophy Pro',
          'Global Genius',
          'Future Forecaster',
          'Abstract Artist',
          'Rhetoric Rock',
          'Policy Pundit',
          'Ethics Envoy',
          'Visionary Voice'
        ]
      };

      final tierNames = names[tier]!;
      final title = '${tierNames[index % tierNames.length]} $levelNum';

      return SpeakingLevelModel(
        level: levelNum,
        title: title,
        challenges: _generateSpeakingChallenges(levelNum),
      );
    });
  }

  List<SpeakingChallengeModel> _generateSpeakingChallenges(int level) {
    int challengeCount = 1;
    List<SpeakingChallengeModel> challenges = [];
    for (int i = 0; i < challengeCount; i++) {
      challenges.add(_generateProceduralSpeakingChallenge(level, i));
    }
    return challenges;
  }

  SpeakingChallengeModel _generateProceduralSpeakingChallenge(
      int level, int index) {
    int seed = level * 10 + index;
    String difficulty = 'Beginner';
    if (level > 33) difficulty = 'Intermediate';
    if (level > 66) difficulty = 'Advanced';

    final beginnerPrompts = [
      {
        't': 'Morning Bliss',
        'p': 'Describe your ideal breakfast and why you enjoy it.',
        'd': 30
      },
      {
        't': 'Hobby Hub',
        'p': 'What is your favorite hobby and how did you start it?',
        'd': 30
      },
      {
        't': 'Weather Wise',
        'p':
            'Talk about your favorite type of weather and what you do during it.',
        'd': 30
      },
      {
        't': 'Pet Party',
        'p': 'Describe your pet or a pet you would like to have.',
        'd': 30
      },
      {
        't': 'Home Tour',
        'p': 'Describe your favorite room in your house.',
        'd': 45
      },
      {
        't': 'Weekend Fun',
        'p': 'What do you usually do on Saturdays?',
        'd': 30
      },
      {
        't': 'Foodie Faith',
        'p': 'Tell me about the best meal you ever ate.',
        'd': 45
      },
      {
        't': 'App Life',
        'p': 'Which mobile app do you use the most and why?',
        'd': 30
      },
    ];

    final intermediatePrompts = [
      {
        't': 'City vs Country',
        'p':
            'Which do you prefer: living in a busy city or a quiet village? Explain.',
        'd': 60
      },
      {
        't': 'Travel Dreams',
        'p': 'If you could travel anywhere tomorrow, where would you go? Why?',
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
        'p': 'What is your favorite childhood memory? Describe it in detail.',
        'd': 60
      },
      {
        't': 'Work World',
        'p': 'Do you think remote work is better than office work? Why?',
        'd': 90
      },
      {
        't': 'Music Mood',
        'p': 'How does music influence your mood during the day?',
        'd': 60
      },
      {
        't': 'Linguistic Luck',
        'p': 'Why did you choose to learn English? What is the hardest part?',
        'd': 90
      },
    ];

    final advancedPrompts = [
      {
        't': 'Future Self',
        'p':
            'Where do you see yourself in five years? What are your aspirations?',
        'd': 90
      },
      {
        't': 'Global Issues',
        'p':
            'What do you think is the biggest challenge facing the world today?',
        'd': 120
      },
      {
        't': 'AI Impact',
        'p':
            'How do you think Artificial Intelligence will change our lives in 20 years?',
        'd': 120
      },
      {
        't': 'Happiness Hunt',
        'p':
            'Define what happiness means to you. Is it a goal or a state of mind?',
        'd': 120
      },
      {
        't': 'Ethics Edge',
        'p': 'Is it ever okay to tell a "white lie"? Explain your reasoning.',
        'd': 120
      },
      {
        't': 'Environmental',
        'p':
            'What can individuals do to combat climate change in their daily lives?',
        'd': 120
      },
      {
        't': 'Success Secret',
        'p': 'What is the most important quality for a leader to have?',
        'd': 120
      },
      {
        't': 'Cultural Shift',
        'p': 'How has the internet changed the way cultures interact?',
        'd': 120
      },
    ];

    List<Map<String, dynamic>> selectedPrompts;
    if (difficulty == 'Beginner') {
      selectedPrompts = beginnerPrompts;
    } else if (difficulty == 'Intermediate') {
      selectedPrompts = intermediatePrompts;
    } else {
      selectedPrompts = advancedPrompts;
    }

    final prompt = selectedPrompts[seed % selectedPrompts.length];

    return SpeakingChallengeModel(
      id: 's_${level}_$index',
      title: prompt['t'] as String,
      prompt: prompt['p'] as String,
      durationSeconds: prompt['d'] as int,
      difficulty: difficulty,
    );
  }

  @override
  Future<List<ScrambleLevelModel>> getScrambleLevels() async {
    return List.generate(100, (index) {
      final levelNum = index + 1;
      return ScrambleLevelModel(
        level: levelNum,
        title: 'Level $levelNum',
        challenges: _generateScrambleChallenges(levelNum),
      );
    });
  }

  List<SentenceChallengeModel> _generateScrambleChallenges(int level) {
    String difficulty = 'Beginner';
    if (level > 20) difficulty = 'Intermediate';
    if (level > 50) difficulty = 'Expert';

    List<SentenceChallengeModel> challenges = [];
    int challengeCount = 3 + (level ~/ 10).clamp(0, 5);
    int levelSeedBase = level * 1000;

    for (int i = 0; i < challengeCount; i++) {
      challenges.add(_generateProceduralScrambleChallenge(
          levelSeedBase + i, difficulty, level, i));
    }
    return challenges;
  }

  SentenceChallengeModel _generateProceduralScrambleChallenge(
      int seed, String difficulty, int level, int index) {
    // Data Banks
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

    int getRandom(int max, int salt) => (seed + salt) % max;
    T getItem<T>(List<T> list, int salt) => list[getRandom(list.length, salt)];

    String tier = 'Intro';
    if (level > 5) tier = 'Beginner';
    if (level > 20) tier = 'Intermediate';
    if (level > 45) tier = 'Advanced';
    if (level > 75) tier = 'Expert';

    if (tier == 'Intro') {
      int template = getRandom(2, 0);
      if (template == 0) {
        String s = getItem(subjects, 1);
        String v = getItem(verbsTransitive, 2);
        String o = getItem(objects, 3);
        sentence = '$s $v $o';
        hint = 'Simple action: Who does what?';
      } else {
        String s = getItem(subjects, 4);
        String a = getItem(adjectives, 5);
        sentence = '$s is $a';
        hint = 'Simple description.';
      }
    } else if (tier == 'Beginner') {
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
      int template = getRandom(3, 30);
      if (template == 0) {
        String c = getItem(connectors, 34);
        String s1 = getItem(subjects, 35);
        String v1 = getItem(verbsIntransitive, 36);
        String s2 = getItem(subjects, 37);
        String v2 = getItem(verbsTransitive, 38);
        String o2 = getItem(objects, 39);
        sentence = '$c $s1 $v1, $s2 $v2 $o2';
        hint = 'Cause and effect logic.';
      } else if (template == 1) {
        String s1 = getItem(subjects, 40);
        String v1 = getItem(verbsTransitive, 41);
        String o1 = getItem(objects, 42);
        String c = getItem(connectors, 43);
        String s2 = getItem(subjects, 44);
        String a = getItem(adjectives, 45);
        sentence = '$s1 $v1 $o1 $c $s2 is $a';
        hint = 'Link two related ideas.';
      } else {
        String s = getItem(abstractNouns, 46);
        String v = getItem(complexVerbs, 47);
        String o = getItem(abstractNouns, 48);
        String p = getItem(places, 49);
        sentence = '$s $v $o $p';
        hint = 'Abstract concepts in context.';
      }
    } else {
      int template = getRandom(3, 60);
      if (template == 0) {
        String s1 = getItem(abstractNouns, 50);
        String a = getItem(adjectives, 51);
        String c = getItem(connectors, 52);
        String s2 = getItem(abstractNouns, 53);
        String v = getItem(complexVerbs, 54);
        String o = getItem(abstractNouns, 55);
        sentence = '$s1 is $a $c $s2 $v $o';
        hint = 'A complex philosophical statement.';
      } else if (template == 1) {
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

    sentence = sentence[0].toUpperCase() + sentence.substring(1);

    final words = sentence.split(' ')..shuffle();

    return SentenceChallengeModel(
      id: 'level_${level}_challenge_$index',
      correctSentence: sentence,
      shuffledWords: words,
      hint: hint,
      difficulty: difficulty,
    );
  }

  // --- Word Match ---
  @override
  Future<List<WordMatchLevelModel>> getWordMatchLevels() async {
    return List.generate(100, (index) {
      return WordMatchLevelModel(
        level: index + 1,
        title: 'Word Match ${index + 1}',
        challenges: _generateWordMatchChallenges(index + 1),
      );
    });
  }

  List<WordMatchChallengeModel> _generateWordMatchChallenges(int level) {
    int count = 3;
    List<WordMatchChallengeModel> list = [];
    for (int i = 0; i < count; i++) {
      list.add(_generateProceduralWordMatch(level, i));
    }
    return list;
  }

  WordMatchChallengeModel _generateProceduralWordMatch(int level, int index) {
    // 1. Define tiered vocabularies
    final easySynonyms = [
      {'w': 'Big', 'm': 'Large'},
      {'w': 'Small', 'm': 'Tiny'},
      {'w': 'Happy', 'm': 'Glad'},
      {'w': 'Sad', 'm': 'Unhappy'},
      {'w': 'Fast', 'm': 'Quick'},
      {'w': 'Slow', 'm': 'Sluggish'},
      {'w': 'Hot', 'm': 'Warm'},
      {'w': 'Cold', 'm': 'Chilly'},
      {'w': 'Start', 'm': 'Begin'},
      {'w': 'End', 'm': 'Finish'},
      {'w': 'Rich', 'm': 'Wealthy'},
      {'w': 'Poor', 'm': 'Needy'},
      {'w': 'Hard', 'm': 'Difficult'},
      {'w': 'Easy', 'm': 'Simple'},
      {'w': 'Smart', 'm': 'Clever'},
      {'w': 'Dumb', 'm': 'Stupid'},
      {'w': 'Right', 'm': 'Correct'},
      {'w': 'Wrong', 'm': 'Incorrect'},
      {'w': 'Safe', 'm': 'Secure'},
      {'w': 'Dangerous', 'm': 'Risky'},
    ];

    final mediumSynonyms = [
      {'w': 'Ancient', 'm': 'Old'},
      {'w': 'Modern', 'm': 'New'},
      {'w': 'Create', 'm': 'Make'},
      {'w': 'Destroy', 'm': 'Ruin'},
      {'w': 'Answer', 'm': 'Reply'},
      {'w': 'Ask', 'm': 'Inquire'},
      {'w': 'Beautiful', 'm': 'Pretty'},
      {'w': 'Ugly', 'm': 'Hideous'},
      {'w': 'Brave', 'm': 'Courageous'},
      {'w': 'Scared', 'm': 'Afraid'},
      {'w': 'Calm', 'm': 'Peaceful'},
      {'w': 'Angry', 'm': 'Furious'},
      {'w': 'Bright', 'm': 'Shiny'},
      {'w': 'Dark', 'm': 'Dim'},
      {'w': 'Clean', 'm': 'Tidy'},
      {'w': 'Dirty', 'm': 'Messy'},
      {'w': 'Break', 'm': 'Smash'},
      {'w': 'Fix', 'm': 'Repair'},
      {'w': 'Help', 'm': 'Assist'},
      {'w': 'Hurt', 'm': 'Harm'},
    ];

    final hardSynonyms = [
      {'w': 'Abundant', 'm': 'Plentiful'},
      {'w': 'Scarce', 'm': 'Rare'},
      {'w': 'Accurate', 'm': 'Precise'},
      {'w': 'Vague', 'm': 'Unclear'},
      {'w': 'Benevolent', 'm': 'Kind'},
      {'w': 'Malevolent', 'm': 'Evil'},
      {'w': 'Candid', 'm': 'Honest'},
      {'w': 'Deceptive', 'm': 'Dishonest'},
      {'w': 'Diligent', 'm': 'Hardworking'},
      {'w': 'Lazy', 'm': 'Slothful'},
      {'w': 'Eloquent', 'm': 'Articulate'},
      {'w': 'Mute', 'm': 'Silent'},
      {'w': 'Frugal', 'm': 'Thrifty'},
      {'w': 'Wasteful', 'm': 'Extravagant'},
      {'w': 'Genuine', 'm': 'Authentic'},
      {'w': 'Fake', 'm': 'Counterfeit'},
      {'w': 'Humble', 'm': 'Modest'},
      {'w': 'Arrogant', 'm': 'Proud'},
      {'w': 'Immaculate', 'm': 'Spotless'},
      {'w': 'Filthy', 'm': 'Grimy'},
    ];

    final definitions = [
      {'w': 'Ephemeral', 'm': 'Short-lived'},
      {'w': 'Eternal', 'm': 'Forever'},
      {'w': 'Obtuse', 'm': 'Slow to understand'},
      {'w': 'Acute', 'm': 'Sharp/Severe'},
      {'w': 'Alleviate', 'm': 'Make easier'},
      {'w': 'Aggravate', 'm': 'Make worse'},
      {'w': 'Ambiguous', 'm': 'Unclear'},
      {'w': 'Explicit', 'm': 'Clear/Direct'},
      {'w': 'Apathy', 'm': 'Lack of interest'},
      {'w': 'Empathy', 'm': 'Understanding feelings'},
      {'w': 'Belligerent', 'm': 'Hostile'},
      {'w': 'Peaceful', 'm': 'Non-violent'},
      {'w': 'Bias', 'm': 'Prejudice'},
      {'w': 'Neutral', 'm': 'Unbiased'},
      {'w': 'Brevity', 'm': 'Conciseness'},
      {'w': 'Prolixity', 'm': 'Wordiness'},
      {'w': 'Cacophony', 'm': 'Harsh noise'},
      {'w': 'Harmony', 'm': 'Pleasing sound'},
      {'w': 'Capitulate', 'm': 'Surrender'},
      {'w': 'Resist', 'm': 'Fight back'},
    ];

    // 2. Determine pool based on level
    List<Map<String, String>> pool;
    String type = 'Synonyms';

    if (level <= 20) {
      pool = easySynonyms;
    } else if (level <= 50) {
      pool = mediumSynonyms;
    } else if (level <= 80) {
      pool = hardSynonyms;
    } else {
      pool = definitions;
      type = 'Definitions';
    }

    // 3. Shuffle (pseudo-random based on seed)
    int seed = (level * 100) + (index * 13);

    // Simple deterministic shuffle simulation
    List<Map<String, String>> selected = [];
    List<int> indices = List.generate(pool.length, (i) => i);
    // Fisher-Yates shuffle with seed
    for (int i = indices.length - 1; i > 0; i--) {
      int n = (seed + i * 37) % (i + 1);
      int temp = indices[i];
      indices[i] = indices[n];
      indices[n] = temp;
    }

    // Select 4-6 pairs depending on level
    int pairCount = 4 + (level ~/ 25);
    if (pairCount > 8) pairCount = 8;

    for (int i = 0; i < pairCount; i++) {
      selected.add(pool[indices[i % pool.length]]);
    }

    return WordMatchChallengeModel(
      id: 'wm_${level}_$index',
      instruction: type == 'Definitions'
          ? 'Match words to definitions'
          : 'Match the pairs ($type)',
      pairs: selected
          .map((e) => WordPairModel(word: e['w']!, match: e['m']!))
          .toList(),
    );
  }

  // --- Typing Speed ---
  @override
  Future<List<TypingLevelModel>> getTypingLevels() async {
    return List.generate(100, (index) {
      return TypingLevelModel(
        level: index + 1,
        title: 'Typing Level ${index + 1}',
        challenges: _generateTypingChallenges(index + 1),
      );
    });
  }

  List<TypingChallengeModel> _generateTypingChallenges(int level) {
    final texts = [
      "The quick brown fox jumps over the lazy dog.",
      "Practice makes perfect, so keep typing everyday.",
      "Flutter is Google's UI toolkit for building natively compiled applications.",
      "To be or not to be, that is the question.",
      "Success is not final, failure is not fatal: it is the courage to continue that counts.",
      "In the middle of difficulty lies opportunity.",
      "A journey of a thousand miles begins with a single step.",
      "Life is what happens when you're busy making other plans.",
      "Get busy living or get busy dying.",
      "You only live once, but if you do it right, once is enough."
    ];

    final text = texts[(level - 1) % texts.length];

    return [
      TypingChallengeModel(
        id: 't_${level}_0',
        textToType: text,
        timeLimitSeconds: (text.length / 3)
            .ceil()
            .clamp(10, 60), // Dynamic time based on length
        difficulty: level > 50 ? 'Advanced' : 'Beginner',
      )
    ];
  }

  // --- Dictation ---
  @override
  Future<List<DictationLevelModel>> getDictationLevels() async {
    return List.generate(100, (index) {
      return DictationLevelModel(
        level: index + 1,
        title: 'Dictation ${index + 1}',
        challenges: _generateDictationChallenges(index + 1),
      );
    });
  }

  List<DictationChallengeModel> _generateDictationChallenges(int level) {
    final sentences = [
      {"t": "The sun is shining today.", "h": "Weather"},
      {"t": "I like to eat apples and bananas.", "h": "Fruit"},
      {"t": "She went to the library to read.", "h": "Place"},
      {"t": "My favorite color is blue.", "h": "Color"},
      {"t": "Can you help me with my homework?", "h": "Question"},
      {"t": "The quick brown fox jumps.", "h": "Animal"},
      {"t": "Elephants are the largest land animals.", "h": "Fact"},
      {"t": "It is important to sleep well.", "h": "Health"},
      {"t": "Technology changes the world fast.", "h": "Tech"},
      {"t": "Music brings people together.", "h": "Art"},
    ];

    final item = sentences[(level - 1) % sentences.length];

    return [
      DictationChallengeModel(
        id: 'd_${level}_0',
        correctText: item['t']!,
        hint: item['h']!,
        difficulty: level > 5 ? 'Intermediate' : 'Beginner',
      )
    ];
  }

  // --- Reading ---
  @override
  Future<List<ReadingLevelModel>> getReadingLevels() async {
    return List.generate(100, (index) {
      return ReadingLevelModel(
        level: index + 1,
        title: 'Reading ${index + 1}',
        challenges: _generateReadingChallenges(index + 1),
      );
    });
  }

  List<ReadingChallengeModel> _generateReadingChallenges(int level) {
    final passages = [
      {
        "title": "The Park",
        "passage":
            "John went to the park. He saw a big dog playing with a ball.",
        "question": "What was the dog doing?",
        "options": [
          "Sleeping",
          "Playing with a ball",
          "Eating",
          "Running away"
        ],
        "correct": 1
      },
      {
        "title": "Morning Routine",
        "passage":
            "Sarah wakes up at 7 AM. She eats toast and drinks coffee before work.",
        "question": "What does Sarah drink?",
        "options": ["Tea", "Juice", "Water", "Coffee"],
        "correct": 3
      },
      {
        "title": "Space Travel",
        "passage":
            "Astronauts wear special suits to survive in space. There is no air to breathe.",
        "question": "Why do astronauts wear suits?",
        "options": ["To look cool", "To breathe", "To sleep", "To eat"],
        "correct": 1
      },
      {
        "title": "Penguins",
        "passage":
            "Penguins are birds but they cannot fly. They swim very well in cold water.",
        "question": "Can penguins fly?",
        "options": ["Yes", "No", "Only at night", "Sometimes"],
        "correct": 1
      },
      {
        "title": "The Ocean",
        "passage":
            "The ocean covers most of the Earth. It is full of salt water and many fish.",
        "question": "Is the ocean water fresh?",
        "options": ["Yes", "No, it's salty", "It's sweet", "It is empty"],
        "correct": 1
      }
    ];

    final item = passages[(level - 1) % passages.length];

    return [
      ReadingChallengeModel(
        id: 'r_${level}_0',
        title: item['title'] as String,
        passage: item['passage'] as String,
        question: item['question'] as String,
        options: item['options'] as List<String>,
        correctOptionIndex: item['correct'] as int,
      )
    ];
  }

  // --- Rapid Fire ---
  @override
  Future<List<RapidFireLevelModel>> getRapidFireLevels() async {
    return List.generate(100, (index) {
      return RapidFireLevelModel(
        level: index + 1,
        title: 'Rapid Fire ${index + 1}',
        challenges: _generateRapidFireChallenges(index + 1),
      );
    });
  }

  List<RapidFireChallengeModel> _generateRapidFireChallenges(int level) {
    final questions = [
      {
        "q": "Name a fruit that is red.",
        "a": ["Apple", "Strawberry", "Cherry", "Tomato", "Raspberry"]
      },
      {
        "q": "Name a planet in our solar system.",
        "a": [
          "Mercury",
          "Venus",
          "Earth",
          "Mars",
          "Jupiter",
          "Saturn",
          "Uranus",
          "Neptune"
        ]
      },
      {
        "q": "Name a primary color.",
        "a": ["Red", "Blue", "Yellow"]
      },
      {
        "q": "Name a continent.",
        "a": [
          "Asia",
          "Africa",
          "Europe",
          "North America",
          "South America",
          "Australia",
          "Antarctica"
        ]
      },
      {
        "q": "Name a month with 30 days.",
        "a": ["April", "June", "September", "November"]
      },
    ];

    final item = questions[(level - 1) % questions.length];

    return [
      RapidFireChallengeModel(
        id: 'rf_${level}_0',
        question: item['q'] as String,
        acceptableAnswers: item['a'] as List<String>,
        timeLimitSeconds: 7, // Slightly increased base time
      )
    ];
  }
}
