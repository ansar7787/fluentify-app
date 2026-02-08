import 'package:dio/dio.dart';
import '../models/session_model.dart';

abstract class SessionRemoteDataSource {
  Future<List<SessionModel>> getSessions();
}

class SessionRemoteDataSourceImpl implements SessionRemoteDataSource {
  final Dio dio;

  SessionRemoteDataSourceImpl(this.dio);

  @override
  Future<List<SessionModel>> getSessions() async {
    // try {
    //   final response = await dio.get('/sessions');
    //   return (response.data as List).map((e) => SessionModel.fromJson(e)).toList();
    // } catch (e) {
    // Fallback Mock Data for demo until backend ready
    return [
      SessionModel(
        id: '1',
        title: 'IELTS Speaking Prep',
        mentorName: 'Sarah Jenkins',
        mentorAvatar: '',
        scheduledAt: DateTime.now().add(const Duration(hours: 2)),
        durationMinutes: 45,
        status: 'active',
        meetingId: 'demo_channel_1',
      ),
      SessionModel(
        id: '2',
        title: 'Business English',
        mentorName: 'David Chen',
        mentorAvatar: '',
        scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
        durationMinutes: 60,
        status: 'completed',
      ),
    ];
    // }
  }
}
