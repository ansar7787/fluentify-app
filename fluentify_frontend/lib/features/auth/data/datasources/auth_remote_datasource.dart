import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(
      String email, String password, String fullName);
  Future<Map<String, dynamic>> firebaseLogin(String token);
  Future<void> forgotPassword(String email);
  Future<Map<String, dynamic>> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> register(
      String email, String password, String fullName) async {
    final response = await dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'fullName': fullName,
    });
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> firebaseLogin(String token) async {
    final response = await dio.post('/auth/firebase', data: {
      'token': token,
    });
    return response.data;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await dio.post('/auth/forgot-password', data: {
      'email': email,
    });
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    final response = await dio.get('/auth/profile');
    return response.data;
  }
}
