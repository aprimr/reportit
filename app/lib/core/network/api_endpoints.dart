class ApiEndpoints {
  static const String baseUrl = "http://192.168.100.30:8000";
  static const String apiVersion = "/api/v1";

  // Auth endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String refresh = '$apiVersion/auth/refresh';
  // (protected)
  static const String logout = '$apiVersion/auth/logout';
  static const String logoutAll = '$apiVersion/auth/logout-all';

  // User endpoints (protected)
  static const String fetchProfile = '$apiVersion/user/';
  static const String updateFullname = '$apiVersion/user/fullname';
  static const String changePassword = '$apiVersion/user/password';
}
