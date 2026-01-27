import '../datasources/auth_remote_datasource.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, UserEntity>> login(
      String email, String password) async {
    try {
      final result = await remoteDataSource.login(email, password);
      await _saveToken(result['access_token']);
      return Right(UserModel.fromJson(result['user']));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(
      String email, String password, String fullName) async {
    try {
      final result = await remoteDataSource.register(email, password, fullName);
      await _saveToken(result['access_token']);
      return Right(UserModel.fromJson(result['user']));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> firebaseLogin(String token) async {
    try {
      final result = await remoteDataSource.firebaseLogin(token);
      await _saveToken(result['access_token']);
      return Right(UserModel.fromJson(result['user']));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> googleLogin() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Force account chooser every time
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return const Left(ServerFailure('Google Sign-In cancelled'));
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
        return firebaseLogin(idToken);
      } else {
        return const Left(
            ServerFailure('Failed to retrieve Firebase ID Token'));
      }
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final token = await secureStorage.read(key: 'access_token');
      if (token == null) {
        return const Left(NetworkFailure('No session found'));
      }
      final result = await remoteDataSource.getProfile();
      return Right(UserModel.fromJson(result));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(key: 'access_token');
  }

  Future<void> _saveToken(String token) async {
    await secureStorage.write(key: 'access_token', value: token);
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
          final msg = data['message'];
          if (msg is List) {
            message = msg.join(', ');
          } else {
            message = msg?.toString() ?? 'Something went wrong on the server.';
          }
        } else if (data is String) {
          // Sometimes HTML is returned (e.g. 404/500/Proxy errors)
          if (data.contains('<!DOCTYPE html>')) {
            message = 'Server Error (HTML Response)';
          } else {
            message = data;
          }
        } else if (data is List) {
          message = data.join(', ');
        } else {
          message = 'Something went wrong on the server.';
        }

        return ServerFailure(message);
      }
      return const NetworkFailure(
          'Unable to connect to the server. Please check your network.');
    }
    return ServerFailure(e.toString());
  }
}
