import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fluentify/core/error/failures.dart';
import '../../domain/entities/speaking_coach_feedback_entity.dart';
import '../../domain/repositories/speaking_coach_repository.dart';
import '../datasources/speaking_coach_remote_datasource.dart';
import '../models/speaking_coach_feedback_model.dart';

class SpeakingCoachRepositoryImpl implements SpeakingCoachRepository {
  final SpeakingCoachRemoteDataSource remoteDataSource;

  SpeakingCoachRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SpeakingCoachFeedbackEntity>> analyzeSpeaking({
    required String transcript,
    String? prompt,
    String? learnerLevel,
  }) async {
    try {
      final response = await remoteDataSource.analyzeSpeaking(
        transcript: transcript,
        prompt: prompt,
        learnerLevel: learnerLevel,
      );
      return Right(SpeakingCoachFeedbackModel.fromJson(response));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(Object e) {
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return ServerFailure(data['message'].toString());
      }
      if (statusCode == 401) {
        return const ServerFailure('Please login again to continue.');
      }
      return const NetworkFailure('Unable to analyze speaking right now.');
    }
    return ServerFailure(e.toString());
  }
}
