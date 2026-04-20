class ApiEndpoints {
  // ⚠️ ئەمە بگۆڕە بۆ IPی کۆمپیوتەرەکەت
  // ئەگەر Android Emulator: 10.0.2.2
  // ئەگەر مۆبایلی ڕاستەقینە: IPی WiFi کۆمپیوتەرەکەت (مسالا: 192.168.1.5)
  static const String baseUrl = 'http://192.168.43.140:8080/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String verifyEmail = '/auth/verify-email';

  // Complaints
  static const String complaints = '/complaints';
  static const String myComplaints = '/complaints/my';
  static const String complaintDetail = '/complaints/';
  static const String complaintImages = '/complaints/{id}/images';
  static const String support = '/complaints/{id}/support';
  static const String comments = '/complaints/{id}/comments';
  static const String feedback = '/complaints/{id}/feedback';
  static const String mapComplaints = '/complaints/map';

  // User
  static const String profile = '/users/profile';
  static const String coins = '/users/coins';

  // Feed
  static const String feed = '/complaints';
}
