import 'dart:io';

class AppConstants {
  static const String appName = 'Fluentify';
  static String get apiBaseUrl {
    if (Platform.isAndroid) {
      // Using Tunnelmole for password-free public access
      return 'https://kugbfb-ip-202-122-23-201.tunnelmole.net';
    }
    return 'http://localhost:3000';
  }

  // Storage Keys
  static const String tokenKey = 'access_token';
  static const String userKey = 'user_data';

  // Agora
  static const String agoraAppId = 'e377b4bbf6934abbbe4dc69f1937095c';
}
