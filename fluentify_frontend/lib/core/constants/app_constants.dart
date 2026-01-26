import 'dart:io';

class AppConstants {
  static const String appName = 'Fluentify';
  static String get apiBaseUrl {
    if (Platform.isAndroid) {
      // For Physical Device, use your computer's local IP
      return 'http://192.168.1.45:3000';
    }
    return 'http://localhost:3000';
  }

  // Storage Keys
  static const String tokenKey = 'access_token';
  static const String userKey = 'user_data';

  // Agora
  static const String agoraAppId = 'e377b4bbf6934abbbe4dc69f1937095c';
}
