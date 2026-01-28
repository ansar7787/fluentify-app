import 'package:dio/dio.dart';

import '../models/grammar_level_model.dart';
import '../models/grammar_challenge_model.dart';
import '../models/speaking_level_model.dart';
import '../models/speaking_challenge_model.dart';
import '../models/scramble_level_model.dart';
import '../models/sentence_challenge_model.dart';
import '../models/word_match_models.dart';
import '../models/typing_models.dart';
import '../models/dictation_models.dart';
import '../models/reading_models.dart';
import '../models/rapid_fire_models.dart';

abstract class GameRemoteDataSource {
  Future<List<GrammarLevelModel>> getGrammarLevels();
  Future<List<SpeakingLevelModel>> getSpeakingLevels();
  Future<List<ScrambleLevelModel>> getScrambleLevels();
  Future<List<WordMatchLevelModel>> getWordMatchLevels();
  Future<List<TypingLevelModel>> getTypingLevels();
  Future<List<DictationLevelModel>> getDictationLevels();
  Future<List<ReadingLevelModel>> getReadingLevels();
  Future<List<RapidFireLevelModel>> getRapidFireLevels();

  // Admin methods
  Future<void> createGameLevel(Map<String, dynamic> levelData);
  Future<List<dynamic>> generateAiContent(
      String gameType, String topic, String level);
}

class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final Dio dio;

  GameRemoteDataSourceImpl(this.dio);

  Future<List<T>> _getLevels<T>(
      String type, T Function(Map<String, dynamic>) mapper) async {
    try {
      final response =
          await dio.get('/game/levels', queryParameters: {'type': type});
      final data = response.data as List;
      return data.map((e) => mapper(e)).toList();
    } catch (e) {
      // If server fails or no data, rethrow to trigger fallback
      throw e;
    }
  }

  @override
  Future<void> createGameLevel(Map<String, dynamic> levelData) async {
    await dio.post('/game/levels', data: levelData);
  }

  @override
  Future<List<dynamic>> generateAiContent(
      String gameType, String topic, String level) async {
    final response = await dio.post('/ai/generate', data: {
      'gameType': gameType,
      'topic': topic,
      'level': level,
      'count': 5, // Defaulting to 5 for now
    });
    return response.data as List<dynamic>;
  }

  @override
  Future<List<GrammarLevelModel>> getGrammarLevels() async {
    return _getLevels('grammar', (json) {
      final content = json['content'] as List? ?? [];
      final challenges =
          content.map((c) => GrammarChallengeModel.fromJson(c)).toList();
      return GrammarLevelModel(
        level: json['levelNumber'],
        title: json['title'],
        challenges: challenges,
      );
    });
  }

  @override
  Future<List<SpeakingLevelModel>> getSpeakingLevels() async {
    return _getLevels('speaking', (json) {
      final content = json['content'] as List? ?? [];
      final challenges =
          content.map((c) => SpeakingChallengeModel.fromJson(c)).toList();
      return SpeakingLevelModel(
        level: json['levelNumber'],
        title: json['title'],
        challenges: challenges,
      );
    });
  }

  @override
  Future<List<ScrambleLevelModel>> getScrambleLevels() async {
    return _getLevels('scramble', (json) {
      final content = json['content'] as List? ?? [];
      final challenges =
          content.map((c) => SentenceChallengeModel.fromJson(c)).toList();
      return ScrambleLevelModel(
        level: json['levelNumber'],
        title: json['title'],
        challenges: challenges,
      );
    });
  }

  @override
  Future<List<WordMatchLevelModel>> getWordMatchLevels() async {
    return _getLevels('word_match', (json) {
      final content = json['content'] as List? ?? [];
      final challenges =
          content.map((c) => WordMatchChallengeModel.fromJson(c)).toList();
      return WordMatchLevelModel(
        level: json['levelNumber'],
        title: json['title'],
        challenges: challenges,
      );
    });
  }

  @override
  Future<List<TypingLevelModel>> getTypingLevels() async {
    return _getLevels('typing', (json) {
      final content = json['content'] as List? ?? [];
      final challenges =
          content.map((c) => TypingChallengeModel.fromJson(c)).toList();
      return TypingLevelModel(
        level: json['levelNumber'],
        title: json['title'],
        challenges: challenges,
      );
    });
  }

  @override
  Future<List<DictationLevelModel>> getDictationLevels() async {
    return _getLevels('dictation', (json) {
      final content = json['content'] as List? ?? [];
      final challenges =
          content.map((c) => DictationChallengeModel.fromJson(c)).toList();
      return DictationLevelModel(
        level: json['levelNumber'],
        title: json['title'],
        challenges: challenges,
      );
    });
  }

  @override
  Future<List<ReadingLevelModel>> getReadingLevels() async {
    return _getLevels('reading', (json) {
      final content = json['content'] as List? ?? [];
      final challenges =
          content.map((c) => ReadingChallengeModel.fromJson(c)).toList();
      return ReadingLevelModel(
        level: json['levelNumber'],
        title: json['title'],
        challenges: challenges,
      );
    });
  }

  @override
  Future<List<RapidFireLevelModel>> getRapidFireLevels() async {
    return _getLevels('rapid_fire', (json) {
      final content = json['content'] as List? ?? [];
      final challenges =
          content.map((c) => RapidFireChallengeModel.fromJson(c)).toList();
      return RapidFireLevelModel(
        level: json['levelNumber'],
        title: json['title'],
        challenges: challenges,
      );
    });
  }
}
