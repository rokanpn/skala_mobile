import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationService {
  static const String baseUrl =
      "http://192.168.0.106:8088/api/v1/notifications";

  static Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<List<NotificationModel>> getAll() async {
    final token = await _token();
    try {
      final res = await http
          .get(Uri.parse(baseUrl), headers: {"Authorization": "Bearer $token"});
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => NotificationModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<int> getUnreadCount() async {
    final token = await _token();
    try {
      final res = await http.get(Uri.parse("$baseUrl/unread-count"),
          headers: {"Authorization": "Bearer $token"});
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['count'] ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  static Future<void> markAllRead() async {
    final token = await _token();
    try {
      await http.post(Uri.parse("$baseUrl/mark-read"),
          headers: {"Authorization": "Bearer $token"});
    } catch (_) {}
  }
}
