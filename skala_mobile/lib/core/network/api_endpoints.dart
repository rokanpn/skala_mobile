class ApiEndpoints {
  static const String baseUrl = 'https://your-api.com/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Complaints
  static const String complaints = '/complaints';
  static const String myComplaints = '/complaints/my';
  static const String complaintDetail = '/complaints/';

  // Feed
  static const String feed = '/feed';
  static const String support = '/complaints/{id}/support';

  // Profile
  static const String profile = '/user/profile';
  static const String coins = '/user/coins';
}
