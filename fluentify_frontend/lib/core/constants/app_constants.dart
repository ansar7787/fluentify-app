class AppConstants {
  static const String appName = 'Fluentify';
  // Toggle this to switch between Localhost and Production
  static const bool useLocalBackend = true;

  static String get apiBaseUrl {
    if (useLocalBackend) {
      // Host machine LAN IP for Physical Device
      return 'http://192.168.1.51:3000';
    }
    return 'https://fluentify-app-1bul.vercel.app';
  }

  // Storage Keys
  static const String tokenKey = 'access_token';
  static const String userKey = 'user_data';

  // Agora
  static const String agoraAppId = 'e377b4bbf6934abbbe4dc69f1937095c';
}
