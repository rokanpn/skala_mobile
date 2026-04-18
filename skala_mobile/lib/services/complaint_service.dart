import 'dart:convert';
import 'package:flutter/foundation.dart'; // ✅ زیاد کرا بۆ debugPrint
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/complaint_model.dart';

class ComplaintService {
  static const String baseUrl = 'https://your-api.com/api/v1';

  // Get all complaints
  static Future<List<ComplaintModel>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/complaints'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ComplaintModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching complaints: $e');
      return [];
    }
  }

  // ✅ میسۆدی نوێ: getMine - بۆ وەرگرتنی سکاڵاکانی من
  static Future<List<ComplaintModel>> getMine() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/complaints/my'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ComplaintModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching my complaints: $e');
      return [];
    }
  }

  // ✅ میسۆدی نوێ: create - بۆ دروستکردنی سکاڵای نوێ
  static Future<bool> create({
    required String title,
    required String description,
    String? mediaUrl,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/complaints'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': title,
          'description': description,
          'media_url': mediaUrl,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error creating complaint: $e');
      return false;
    }
  }

  // Support a complaint
  static Future<bool> support(int complaintId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/complaints/$complaintId/support'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error supporting complaint: $e');
      return false;
    }
  }
}
