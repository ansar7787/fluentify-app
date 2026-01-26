import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/mentor_model.dart';
import '../models/booking_model.dart';

abstract class MentorRemoteDataSource {
  Future<MentorModel> createProfile(Map<String, dynamic> data);
  Future<List<MentorModel>> getAllMentors(Map<String, dynamic>? filters);
  Future<MentorModel> getMentorById(String id);
  Future<BookingModel> createBooking(Map<String, dynamic> data);
  Future<List<BookingModel>> getUserBookings();
}

class MentorRemoteDataSourceImpl implements MentorRemoteDataSource {
  final Dio dio;

  MentorRemoteDataSourceImpl({required this.dio});

  @override
  Future<MentorModel> createProfile(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/mentor/profile', data: data);
      if (response.statusCode == 201) {
        return MentorModel.fromJson(response.data['data']);
      } else {
        throw ServerException(message: 'Failed to create profile');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Unknown error');
    }
  }

  @override
  Future<List<MentorModel>> getAllMentors(Map<String, dynamic>? filters) async {
    try {
      final response = await dio.get('/mentor/all', queryParameters: filters);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => MentorModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to fetch mentors');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Unknown error');
    }
  }

  @override
  Future<MentorModel> getMentorById(String id) async {
    try {
      final response = await dio.get('/mentor/$id');
      if (response.statusCode == 200) {
        return MentorModel.fromJson(response.data['data']);
      } else {
        throw ServerException(message: 'Failed to fetch mentor');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Unknown error');
    }
  }

  @override
  Future<BookingModel> createBooking(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/mentor/booking', data: data);
      if (response.statusCode == 201) {
        return BookingModel.fromJson(response.data['data']);
      } else {
        throw ServerException(message: 'Failed to create booking');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Unknown error');
    }
  }

  @override
  Future<List<BookingModel>> getUserBookings() async {
    try {
      final response = await dio.get('/mentor/bookings/user');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => BookingModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to fetch bookings');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Unknown error');
    }
  }
}
