import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluentify/config/theme/app_theme.dart';
import 'package:fluentify/core/di/service_locator.dart';
import 'package:fluentify/core/services/notification_service.dart';
import 'package:fluentify/config/routes/app_routes.dart';
import 'package:fluentify/core/constants/app_constants.dart';
import 'package:fluentify/firebase_options.dart';
import 'package:fluentify/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fluentify/features/mission/presentation/bloc/mission_bloc.dart';
import 'package:fluentify/features/auth/domain/repositories/auth_repository.dart';
import 'package:fluentify/features/auth/domain/usecases/login_usecase.dart';
import 'package:fluentify/features/auth/domain/usecases/register_usecase.dart';
import 'package:fluentify/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:fluentify/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:fluentify/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:fluentify/features/auth/presentation/bloc/auth_event.dart';
import 'package:fluentify/features/mission/domain/usecases/get_missions_usecase.dart';
import 'package:fluentify/features/mission/domain/usecases/submit_mission_usecase.dart';
import 'package:fluentify/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:fluentify/features/user/presentation/bloc/user_bloc.dart';
import 'package:fluentify/features/user/presentation/bloc/leaderboard_bloc.dart';
import 'package:fluentify/features/peer/presentation/bloc/peer_bloc.dart';
import 'package:fluentify/core/theme/theme_cubit.dart';
import 'package:fluentify/core/network/bloc/network_bloc.dart';
import 'package:fluentify/core/widgets/no_internet_screen.dart';
import 'package:fluentify/features/speaking_partner/presentation/bloc/speaking_partner_bloc.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize dependencies
  await setupServiceLocator();
  await getIt<NotificationService>().initialize();

  runApp(const FluentifyApp());
}

class FluentifyApp extends StatelessWidget {
  const FluentifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (_) => AuthBloc(
            loginUseCase: getIt<LoginUseCase>(),
            registerUseCase: getIt<RegisterUseCase>(),
            resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
            googleLoginUseCase: getIt<GoogleLoginUseCase>(),
            checkAuthStatusUseCase: getIt<CheckAuthStatusUseCase>(),
            authRepository: getIt<AuthRepository>(),
          )..add(AuthCheckStatus()),
        ),
        BlocProvider(
          create: (_) => MissionBloc(
            getMissionsUseCase: getIt<GetMissionsUseCase>(),
            submitMissionUseCase: getIt<SubmitMissionUseCase>(),
          ),
        ),
        BlocProvider(
          create: (_) => getIt<PaymentBloc>(),
        ),
        BlocProvider(
          create: (_) => getIt<UserBloc>(),
        ),
        BlocProvider(
          create: (_) => getIt<LeaderboardBloc>(),
        ),
        BlocProvider(
          create: (_) => getIt<PeerBloc>(),
        ),
        BlocProvider(
          create: (_) => getIt<SpeakingPartnerBloc>(),
        ),
        BlocProvider(create: (_) => NetworkBloc()..add(NetworkObserve())),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // Standard iPhone size
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                title: AppConstants.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                initialRoute: AppRoutes.splash,
                routes: AppRoutes.routes,
                builder: (context, child) {
                  return BlocBuilder<NetworkBloc, NetworkState>(
                    builder: (context, state) {
                      if (state is NetworkFailure) {
                        return const NoInternetScreen();
                      }
                      return child!;
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
