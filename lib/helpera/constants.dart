class AppConstants {
  // API
  // API base URL for local json-server during development.
  // - Android emulator: http://10.0.2.2:3000
  // - iOS simulator: http://localhost:3000
  // - Real device: http://<PC-IP>:3000
  static const String apiBaseUrl = 'http://10.0.2.2:3000';
  static const int apiConnectTimeout = 10; // seconds
  static const int apiReceiveTimeout = 10; // seconds
  // json-server-auth endpoints
  static const String registerEndpoint = '/register';
  static const String loginEndpoint = '/login';

  // Hive Boxes
  static const String boxTasks = 'tasks';
  static const String boxCategories = 'categories';
  static const String boxSettings = 'settings';

  // Hive Keys
  static const String keyToken = 'accessToken';
  static const String keyUser = 'user_data';
  static const String keyIsDark = 'isDark';
  static const String keyLanguage = 'language';

  // Defaults / Demo
  static const String demoUsername = 'shaker@gmail.com';
  static const String demoPassword = 'shaker';
}
