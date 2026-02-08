import 'package:dio/dio.dart';

abstract class SpeakingCoachRemoteDataSource {
  Future<Map<String, dynamic>> analyzeSpeaking({
    required String transcript,
    String? prompt,
    String? learnerLevel,
  });
}

class SpeakingCoachRemoteDataSourceImpl implements SpeakingCoachRemoteDataSource {
  final Dio dio;

  SpeakingCoachRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> analyzeSpeaking({
    required String transcript,
    String? prompt,
    String? learnerLevel,
  }) async {
    final response = await dio.post(
      '/ai/speaking/analyze',
      data: {
        'transcript': transcript,
        if (prompt != null && prompt.isNotEmpty) 'prompt': prompt,
        if (learnerLevel != null && learnerLevel.isNotEmpty)
          'learnerLevel': learnerLevel,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
