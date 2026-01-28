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
    return [
      GrammarLevelModel(
        level: 1,
        title: 'Beginner Basics',
        challenges: [
          GrammarChallengeModel(
            id: 'g_1_1',
            question: 'She ___ to school everyday.',
            options: ['go', 'goes', 'going', 'gone'],
            correctOptionIndex: 1,
            explanation: '3rd person singular takes "goes".',
            difficulty: 'Beginner',
          ),
          GrammarChallengeModel(
            id: 'g_1_2',
            question: '___ you like pizza?',
            options: ['Do', 'Does', 'Is', 'Are'],
            correctOptionIndex: 0,
            explanation: 'Use "Do" for questions with "you".',
            difficulty: 'Beginner',
          ),
        ],
      )
    ];
  }

  @override
  Future<List<SpeakingLevelModel>> getSpeakingLevels() async {
    return [
      SpeakingLevelModel(
        level: 1,
        title: 'Self Introduction',
        challenges: [
          SpeakingChallengeModel(
            id: 's_1_1',
            title: 'Intro',
            prompt: 'Introduce yourself and say hello.',
            durationSeconds: 30,
            difficulty: 'Beginner',
          )
        ],
      )
    ];
  }

  @override
  Future<List<ScrambleLevelModel>> getScrambleLevels() async {
    return [
      ScrambleLevelModel(
        level: 1,
        title: 'Simple Sentences',
        challenges: [
          SentenceChallengeModel(
            id: 'scr_1_1',
            correctSentence: 'The cat sleeps on the mat',
            shuffledWords: ['cat', 'mat', 'on', 'The', 'sleeps', 'the'],
            hint: 'Start with "The"',
            difficulty: 'Beginner',
          )
        ],
      )
    ];
  }

  @override
  Future<List<WordMatchLevelModel>> getWordMatchLevels() async {
    return [
      WordMatchLevelModel(level: 1, title: 'Basic Vocabulary', challenges: [
        WordMatchChallengeModel(
            id: 'wm_1_1',
            instruction: 'Match the words.',
            pairs: [
              WordPairModel(word: 'Happy', match: 'Joyful'),
              WordPairModel(word: 'Sad', match: 'Unhappy'),
              WordPairModel(word: 'Big', match: 'Large'),
            ],
            difficulty: 'Beginner')
      ])
    ];
  }

  @override
  Future<List<TypingLevelModel>> getTypingLevels() async {
    return [
      TypingLevelModel(level: 1, title: 'Fast Fingers', challenges: [
        TypingChallengeModel(
            id: 't_1_1',
            textToType: 'The quick brown fox jumps over the lazy dog.',
            timeLimitSeconds: 60,
            difficulty: 'Beginner')
      ])
    ];
  }

  @override
  Future<List<DictationLevelModel>> getDictationLevels() async {
    return [
      DictationLevelModel(level: 1, title: 'Listen Up', challenges: [
        DictationChallengeModel(
            id: 'd_1_1',
            correctText: 'Hello world',
            hint: 'Common greeting',
            audioUrl: 'https://example.com/audio.mp3', // Placeholder
            difficulty: 'Beginner')
      ])
    ];
  }

  @override
  Future<List<ReadingLevelModel>> getReadingLevels() async {
    return [
      ReadingLevelModel(level: 1, title: 'Short Story', challenges: [
        ReadingChallengeModel(
            id: 'r_1_1',
            title: 'Tom and the Cat',
            passage: 'Tom has a cat. The cat is black.',
            question: 'What color is the cat?',
            options: ['Black', 'White', 'Blue'],
            correctOptionIndex: 0,
            difficulty: 'Beginner')
      ])
    ];
  }

  @override
  Future<List<RapidFireLevelModel>> getRapidFireLevels() async {
    return [
      RapidFireLevelModel(level: 1, title: 'Speed Round', challenges: [
        RapidFireChallengeModel(
            id: 'rf_1_1',
            question: 'Opposite of Up?',
            acceptableAnswers: ['Down', 'down'],
            difficulty: 'Beginner')
      ])
    ];
  }
}
