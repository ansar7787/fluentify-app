import 'package:flutter/material.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/mission/presentation/pages/home_page.dart';
import '../../features/payment/presentation/pages/subscription_page.dart';
import '../../features/user/presentation/pages/profile_page.dart';
import '../../features/user/presentation/pages/leaderboard_page.dart';
import '../../features/user/presentation/pages/personal_profile_page.dart';
import '../../features/user/presentation/pages/learning_goals_page.dart';
import '../../features/user/presentation/pages/notifications_page.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot_password';
  static const String home = '/home';
  static const String subscription = '/subscription';
  static const String leaderboard = '/leaderboard';
  static const String profile = '/profile';
  static const String personalProfile = '/personal_profile';
  static const String learningGoals = '/learning_goals';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginPage(),
        register: (context) => const RegisterPage(),
        forgotPassword: (context) => const ForgotPasswordPage(),
        home: (context) => const HomePage(),
        subscription: (context) => const SubscriptionPage(),
        leaderboard: (context) => const LeaderboardPage(),
        profile: (context) => const ProfilePage(),
        personalProfile: (context) => const PersonalProfilePage(),
        learningGoals: (context) => const LearningGoalsPage(),
        notifications: (context) => const NotificationsPage(),
      };
}
