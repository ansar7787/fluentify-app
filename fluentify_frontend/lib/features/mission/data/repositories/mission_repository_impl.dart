import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/mission_repository.dart';
import '../../domain/entities/mission_entity.dart';
import '../datasources/mission_remote_datasource.dart';
import '../models/mission_model.dart';

class MissionRepositoryImpl implements MissionRepository {
  final MissionRemoteDataSource remoteDataSource;

  MissionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<MissionEntity>>> getMissions(
      {String? level}) async {
    try {
      final result = await remoteDataSource.getMissions(level: level);
      final missions = result
          .map((m) => MissionModel.fromJson(m))
          .toList()
          .cast<MissionEntity>();
      return Right(missions);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, MissionSubmissionResultEntity>> submitMission(
      String missionId, String audioPath) async {
    try {
      final result = await remoteDataSource.submitMission(missionId, audioPath);
      final MissionSubmissionResultEntity model =
          MissionSubmissionResultModel.fromJson(result);
      return Right(model);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return const NetworkFailure(
            'Connection timed out. Please check your internet.');
      }
      if (e.response != null) {
        final data = e.response?.data;
        String message;

        if (data is Map<String, dynamic>) {
          message = data['message'] ?? 'Something went wrong on the server.';
        } else if (data is String) {
          // If the response is HTML or plain text (e.g., from Nginx/Tunnelmole)
          if (data.contains('PayloadTooLargeError')) {
            message = 'File is too large to upload.';
          } else {
            // Truncate if too long (e.g. detailed HTML)
            message = data.length > 100
                ? 'Server Error: ${e.response?.statusCode}'
                : data;
          }
        } else {
          message = 'Unexpected error format: ${e.response?.statusCode}';
        }

        if (e.response?.statusCode == 413) {
          message = 'File is too large. Please record a shorter audio.';
        }

        return ServerFailure(message is List
            ? (message as List).join(', ')
            : message.toString());
      }
      return const NetworkFailure(
          'Unable to connect to the server. Please check your network.');
    }
    return ServerFailure(e.toString());
  }
}
