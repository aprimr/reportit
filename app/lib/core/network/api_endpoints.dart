class ApiEndpoints {
  static const String baseUrl = "http://192.168.100.30:8000";
  static const String apiVersion = "/api/v1";

  // Auth endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String refresh = '$apiVersion/auth/refresh';
  // user logout (protected)
  static const String logout = '$apiVersion/auth/logout';
  static const String logoutAll = '$apiVersion/auth/logout-all';
  // admin logout (protected)
  static const String logoutAdmin = '$apiVersion/auth//admin/logout';
  static const String logoutAllAdmin = '$apiVersion/auth//admin/logout-all';

  // User endpoints (protected)
  static const String fetchProfile = '$apiVersion/user/';
  static const String updateFullname = '$apiVersion/user/fullname';
  static const String changePassword = '$apiVersion/user/password';

  static const String fetchAdminProfile = '$apiVersion/admin/';
  static const String updateAdminFullname = '$apiVersion/admin/fullname';
  static const String changeAdminPassword = '$apiVersion/admin/password';

  // Complaint endpoints (protected)
  static const String complaint = '$apiVersion/complaint';
  static const String createComplaint = '$apiVersion/complaint/';
  static const String getMyComplaints = '$apiVersion/complaint/me';
  static const String getAllComplaints = '$apiVersion/complaint/all';
}
