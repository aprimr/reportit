class ApiEndpoints {
  static const String baseUrl = "http://192.168.18.10:8000";
  static const String apiVersion = "/v1";

  // Auth endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String refresh = '$apiVersion/auth/refresh';
  // user logout (protected)
  static const String logout = '$apiVersion/auth/logout';
  static const String logoutAll = '$apiVersion/auth/logout-all';

  // User endpoints (protected)
  static const String fetchProfile = '$apiVersion/user/';
  static const String updateFullname = '$apiVersion/user/fullname';
  static const String changePassword = '$apiVersion/user/password';

  // Complaint endpoints (protected)
  static const String complaint = '$apiVersion/complaint';
  static const String createComplaint = '$apiVersion/complaint/';
  static const String getMyComplaints = '$apiVersion/complaint/me';
  static const String getAllComplaints = '$apiVersion/complaint/all';

  // ADMIN ---
  // admin logout (protected)
  static const String logoutAdmin = '$apiVersion/auth//admin/logout';
  static const String logoutAllAdmin = '$apiVersion/auth//admin/logout-all';

  // admin profile routes
  static const String fetchAdminProfile = '$apiVersion/admin/';
  static const String updateAdminFullname = '$apiVersion/admin/fullname';
  static const String changeAdminPassword = '$apiVersion/admin/password';

  // admin dashboard routes
  static const String adminDashboardStats = '$apiVersion/admin/dashboard';

  static const String getAdminAllComplaints = '$apiVersion/admin/complaints/';

  // complaint actions
  static String adminVerifyComplaint(String id) =>
      '$apiVersion/admin/complaints/$id/verify';
  static String adminRejectComplaint(String id) =>
      '$apiVersion/admin/complaints/$id/reject';
  static String adminResolveComplaint(String id) =>
      '$apiVersion/admin/complaints/$id/resolve';
  static String adminDeleteComplaint(String id) =>
      '$apiVersion/admin/complaints/$id';
}
