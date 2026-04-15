import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/complaint_model.dart';

class ComplaintService {
  static const String baseUrl = "http://192.168.0.106:8088/api/v1/complaints";

  static Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<List<ComplaintModel>> getAll() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => ComplaintModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error: $e");
    }
    return [];
  }

  static Future<bool> create({
    required String title,
    required String description,
    required String category,
    File? mediaFile,
    double? lat,
    double? lng,
  }) async {
    final token = await _token();
    var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.headers['Authorization'] = "Bearer $token";
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['category'] = category;
    if (lat != null) request.fields['latitude'] = lat.toString();
    if (lng != null) request.fields['longitude'] = lng.toString();

    if (mediaFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('media', mediaFile.path));
    }

    var response = await request.send();
    return response.statusCode == 201 || response.statusCode == 200;
  }

  static Future<bool> support(int id) async {
    final token = await _token();
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/$id/support"),
        headers: {"Authorization": "Bearer $token"},
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // مێتۆدی getMine - ئێستا لە ناو کلاسەکەدایە
  static Future<List<ComplaintModel>> getMine() async {
    final token = await _token();
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/mine"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => ComplaintModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching mine: $e");
    }
    return [];
  }

  static Future<bool> supportWithCoins(int complaintId, int amount) async {
    final token = await _token();
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/$complaintId/support"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"coins": amount}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
