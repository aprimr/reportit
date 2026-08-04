class ApiEndpoints {
  static const String baseUrl = "http://192.168.100.30:8000";
  static const String apiVersion = "/api/v1";

  // Auth endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
}
