import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/speaking_scenario_model.dart';
import '../models/chat_turn_model.dart';

abstract class SpeakingPartnerRemoteDataSource {
  Future<List<SpeakingScenarioModel>> getScenarios();
  Future<ChatTurnModel> processTurn({
    required String scenarioId,
    required String transcript,
    required List<Map<String, String>> history,
  });
}

class SpeakingPartnerRemoteDataSourceImpl
    implements SpeakingPartnerRemoteDataSource {
  final Dio dio;

  SpeakingPartnerRemoteDataSourceImpl(this.dio);

  @override
  Future<List<SpeakingScenarioModel>> getScenarios() async {
    final response = await dio.get('/speaking-partner/scenarios');
    return (response.data as List)
        .map((json) => SpeakingScenarioModel.fromJson(json))
        .toList();
  }

  @override
  Future<ChatTurnModel> processTurn({
    required String scenarioId,
    required String transcript, // Now we use this as audioPath
    required List<Map<String, String>> history,
  }) async {
    final formData = FormData.fromMap({
      'scenarioId': scenarioId,
      'history': jsonEncode(history),
      'audio': await MultipartFile.fromFile(transcript, filename: 'turn.m4a'),
    });

    final response = await dio.post('/speaking-partner/turn', data: formData);
    return ChatTurnModel.fromJson(response.data);
  }
}
