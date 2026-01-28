import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../network/auth_interceptor.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/mission/domain/repositories/mission_repository.dart';
import '../../features/mission/data/datasources/mission_remote_datasource.dart';
import '../../features/mission/data/repositories/mission_repository_impl.dart';
import '../../features/user/data/repositories/user_repository_impl.dart';
import '../../features/user/domain/repositories/user_repository.dart';
import '../../features/user/domain/usecases/get_user_profile_usecase.dart';
import '../../features/user/domain/usecases/get_leaderboard_usecase.dart';
import '../../features/user/domain/usecases/get_user_rank_usecase.dart';
import '../../features/user/domain/usecases/update_profile_usecase.dart';
import '../../features/user/presentation/bloc/user_bloc.dart';
import '../../features/user/presentation/bloc/leaderboard_bloc.dart';
import '../services/firebase_storage_service.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/payment/domain/usecases/create_order_usecase.dart';
import '../../features/payment/domain/usecases/verify_payment_usecase.dart';
import '../../features/payment/presentation/bloc/payment_bloc.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/google_login_usecase.dart';
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../../features/mission/domain/usecases/get_missions_usecase.dart';
import '../../features/mission/domain/usecases/submit_mission_usecase.dart';
import '../../features/mentor/data/datasources/mentor_remote_datasource.dart';
import '../../features/mentor/data/repositories/mentor_repository_impl.dart';
import '../../features/mentor/domain/repositories/mentor_repository.dart';
import '../../features/mentor/domain/usecases/get_all_mentors_usecase.dart';
import '../../features/mentor/domain/usecases/create_booking_usecase.dart';
import '../../features/mentor/domain/usecases/get_user_bookings_usecase.dart';
import '../../features/mentor/presentation/bloc/mentor_bloc.dart';
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';
import '../services/notification_service.dart';

import '../../features/game/data/datasources/game_local_data_source.dart';
import '../../features/game/data/datasources/game_remote_data_source.dart';
import '../../features/game/data/repositories/game_repository_impl.dart';
import '../../features/game/domain/repositories/game_repository.dart';
import '../../features/game/domain/usecases/get_grammar_levels_usecase.dart';
import '../../features/game/domain/usecases/get_speaking_levels_usecase.dart';
import '../../features/game/domain/usecases/get_scramble_levels_usecase.dart';
import '../../features/game/domain/usecases/get_word_match_levels_usecase.dart';
import '../../features/game/domain/usecases/get_typing_levels_usecase.dart';
import '../../features/game/domain/usecases/get_dictation_levels_usecase.dart';
import '../../features/game/domain/usecases/get_reading_levels_usecase.dart';
import '../../features/game/domain/usecases/get_rapid_fire_levels_usecase.dart';
import '../../features/game/presentation/bloc/game_bloc.dart';

import '../constants/app_constants.dart';
import '../../core/network/chat_service.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/usecases/connect_chat_usecase.dart';
import '../../features/chat/domain/usecases/send_message_usecase.dart';
import '../../features/chat/domain/usecases/get_chat_messages_usecase.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';

import '../../features/session/data/datasources/session_remote_data_source.dart';
import '../../features/session/data/repositories/session_repository_impl.dart';
import '../../features/session/domain/repositories/session_repository.dart';
import '../../features/session/domain/usecases/get_sessions_usecase.dart';
import '../../features/session/presentation/bloc/session_bloc.dart';

import '../../features/peer/domain/repositories/peer_repository.dart';
import '../../features/peer/data/repositories/peer_repository_impl.dart';
import '../../features/peer/domain/usecases/peer_usecases.dart';
import '../../features/peer/presentation/bloc/peer_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  const secureStorage = FlutterSecureStorage();
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  getIt.registerSingleton<NotificationService>(NotificationService());
  getIt.registerSingleton<FirebaseStorageService>(FirebaseStorageService());

  // HTTP Client
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'FluentifyApp/1.0',
      },
    ),
  );
  getIt.registerSingleton<Dio>(dio);

  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<Dio>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<MissionRemoteDataSource>(
    () => MissionRemoteDataSourceImpl(getIt<Dio>()),
  );

  getIt.registerLazySingleton<MissionRepository>(
    () => MissionRepositoryImpl(getIt<MissionRemoteDataSource>()),
  );

  // Use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => ResetPasswordUseCase(getIt<AuthRepository>()));
  getIt
      .registerLazySingleton(() => GoogleLoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => CheckAuthStatusUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => GetMissionsUseCase(getIt<MissionRepository>()));
  getIt.registerLazySingleton(
      () => SubmitMissionUseCase(getIt<MissionRepository>()));

  // Payment
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(dio: getIt<Dio>()),
  );
  getIt.registerLazySingleton(
      () => CreateOrderUseCase(getIt<PaymentRepository>()));
  getIt.registerLazySingleton(
      () => VerifyPaymentUseCase(getIt<PaymentRepository>()));
  getIt.registerFactory(
    () => PaymentBloc(
      createOrderUseCase: getIt<CreateOrderUseCase>(),
      verifyPaymentUseCase: getIt<VerifyPaymentUseCase>(),
    ),
  );

  // User
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(dio: getIt<Dio>()),
  );
  getIt.registerLazySingleton(
      () => GetUserProfileUseCase(getIt<UserRepository>()));
  getIt.registerLazySingleton(
      () => GetLeaderboardUseCase(getIt<UserRepository>()));
  getIt
      .registerLazySingleton(() => GetUserRankUseCase(getIt<UserRepository>()));
  getIt.registerLazySingleton(
      () => UpdateProfileUseCase(getIt<UserRepository>()));
  getIt.registerFactory(
    () => UserBloc(
      getUserProfileUseCase: getIt<GetUserProfileUseCase>(),
      updateProfileUseCase: getIt<UpdateProfileUseCase>(),
    ),
  );
  getIt.registerFactory(() => LeaderboardBloc(
        getLeaderboardUseCase: getIt<GetLeaderboardUseCase>(),
        getUserRankUseCase: getIt<GetUserRankUseCase>(),
      ));

  // Mentor
  getIt.registerLazySingleton<MentorRemoteDataSource>(
    () => MentorRemoteDataSourceImpl(dio: getIt<Dio>()),
  );
  getIt.registerLazySingleton<MentorRepository>(
    () =>
        MentorRepositoryImpl(remoteDataSource: getIt<MentorRemoteDataSource>()),
  );
  getIt.registerLazySingleton(
    () => GetAllMentorsUseCase(getIt<MentorRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateBookingUseCase(getIt<MentorRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetUserBookingsUseCase(getIt<MentorRepository>()),
  );
  getIt.registerFactory(
    () => MentorBloc(
      getAllMentorsUseCase: getIt<GetAllMentorsUseCase>(),
      createBookingUseCase: getIt<CreateBookingUseCase>(),
    ),
  );

  // Add interceptors
  dio.interceptors.addAll([
    AuthInterceptor(),
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      request: true,
    ),
  ]);

  // Admin
  getIt.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(dio: getIt<Dio>()),
  );
  getIt.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: getIt<AdminRemoteDataSource>()),
  );
  getIt.registerFactory(
    () => AdminBloc(repository: getIt<AdminRepository>()),
  );

  // Game
  getIt.registerLazySingleton<GameLocalDataSource>(
    () => GameLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<GameRemoteDataSource>(
    () => GameRemoteDataSourceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<GameRepository>(
    () => GameRepositoryImpl(
      localDataSource: getIt<GameLocalDataSource>(),
      remoteDataSource: getIt<GameRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetGrammarLevelsUseCase(getIt<GameRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetSpeakingLevelsUseCase(getIt<GameRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetScrambleLevelsUseCase(getIt<GameRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetWordMatchLevelsUseCase(getIt<GameRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetTypingLevelsUseCase(getIt<GameRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetDictationLevelsUseCase(getIt<GameRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetReadingLevelsUseCase(getIt<GameRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetRapidFireLevelsUseCase(getIt<GameRepository>()),
  );

  getIt.registerFactory(
    () => GameBloc(
      getGrammarLevels: getIt<GetGrammarLevelsUseCase>(),
      getSpeakingLevels: getIt<GetSpeakingLevelsUseCase>(),
      getScrambleLevels: getIt<GetScrambleLevelsUseCase>(),
      getWordMatchLevels: getIt<GetWordMatchLevelsUseCase>(),
      getTypingLevels: getIt<GetTypingLevelsUseCase>(),
      getDictationLevels: getIt<GetDictationLevelsUseCase>(),
      getReadingLevels: getIt<GetReadingLevelsUseCase>(),
      getRapidFireLevels: getIt<GetRapidFireLevelsUseCase>(),
    ),
  );

  // Chat
  getIt.registerLazySingleton<ChatService>(() => ChatService());
  getIt.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(getIt<ChatService>()));

  getIt
      .registerLazySingleton(() => ConnectChatUseCase(getIt<ChatRepository>()));
  getIt
      .registerLazySingleton(() => SendMessageUseCase(getIt<ChatRepository>()));
  getIt.registerLazySingleton(
      () => GetChatMessagesUseCase(getIt<ChatRepository>()));

  getIt.registerFactory(() => ChatBloc(
        connectChat: getIt<ConnectChatUseCase>(),
        sendMessage: getIt<SendMessageUseCase>(),
        getChatMessages: getIt<GetChatMessagesUseCase>(),
      ));

  // Session
  getIt.registerLazySingleton<SessionRemoteDataSource>(
      () => SessionRemoteDataSourceImpl(getIt<Dio>()));
  getIt.registerLazySingleton<SessionRepository>(
      () => SessionRepositoryImpl(getIt<SessionRemoteDataSource>()));
  getIt.registerLazySingleton(
      () => GetSessionsUseCase(getIt<SessionRepository>()));
  getIt.registerFactory(
      () => SessionBloc(getSessions: getIt<GetSessionsUseCase>()));

  // Peer
  getIt.registerLazySingleton<PeerRepository>(() => PeerRepositoryImpl());
  getIt.registerLazySingleton(() => JoinQueueUseCase(getIt<PeerRepository>()));
  getIt.registerLazySingleton(() => LeaveQueueUseCase(getIt<PeerRepository>()));
  getIt.registerLazySingleton(
      () => GetMatchStreamUseCase(getIt<PeerRepository>()));
  getIt.registerFactory(() => PeerBloc(
        joinQueueUseCase: getIt<JoinQueueUseCase>(),
        leaveQueueUseCase: getIt<LeaveQueueUseCase>(),
        getMatchStreamUseCase: getIt<GetMatchStreamUseCase>(),
      ));
}
