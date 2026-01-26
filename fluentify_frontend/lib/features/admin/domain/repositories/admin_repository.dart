import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_stats_entity.dart';

abstract class AdminRepository {
  Future<Either<Failure, AdminStatsEntity>> getDashboardStats();
}
