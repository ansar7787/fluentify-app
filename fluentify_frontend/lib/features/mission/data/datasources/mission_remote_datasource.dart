import 'package:dio/dio.dart';

abstract class MissionRemoteDataSource {
  Future<List<dynamic>> getMissions({String? level});
  Future<Map<String, dynamic>> submitMission(
      String missionId, String audioPath);
}

class MissionRemoteDataSourceImpl implements MissionRemoteDataSource {
  final Dio dio;

  MissionRemoteDataSourceImpl(this.dio);

  @override
  Future<List<dynamic>> getMissions({String? level}) async {
    final response = await dio.get('/missions',
        queryParameters: level != null ? {'level': level} : {});
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> submitMission(
      String missionId, String audioPath) async {
    final formData = FormData.fromMap({
      'audio':
          await MultipartFile.fromFile(audioPath, filename: 'submission.m4a'),
    });

    final response =
        await dio.post('/missions/$missionId/submit', data: formData);
    return response.data;
  }
}
