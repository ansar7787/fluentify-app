import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../models/admin_stats_model.dart';

abstract class AdminRemoteDataSource {
  Future<AdminStatsModel> getDashboardStats();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final Dio dio;

  AdminRemoteDataSourceImpl({required this.dio});

  @override
  Future<AdminStatsModel> getDashboardStats() async {
    try {
      final response = await dio.get('/admin/stats');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return AdminStatsModel.fromJson(data);
      } else {
        throw const ServerFailure('Failed to fetch admin stats');
      }
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
