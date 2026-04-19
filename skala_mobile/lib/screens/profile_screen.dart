import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/secure_storage.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  final _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.profile);
      if (mounted) {
        setState(() {
          _user = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    try {
      await _apiClient.dio.post(ApiEndpoints.logout);
    } catch (_) {}
    await SecureStorage.clearAll();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('پرۆفایلەکەم'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ئەوتار
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF1976D2),
              child: Text(
                (_user?['name'] ?? 'U')[0].toUpperCase(),
                style: const TextStyle(fontSize: 36, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _user?['name'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              _user?['email'] ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // کارتی کۆین
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1976D2).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('کۆینەکانم',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 14)),
                      Text(
                        '${_user?['coins'] ?? 0}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.monetization_on,
                      color: Colors.white, size: 50),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ئامارەکان
            Row(
              children: [
                _statCard('سکاڵاکانم', '${_user?['total_complaints'] ?? 0}',
                    Icons.report),
                const SizedBox(width: 12),
                _statCard(
                    'چارەسەرکراو',
                    '${_user?['resolved_complaints'] ?? 0}',
                    Icons.check_circle),
                const SizedBox(width: 12),
                _statCard('پشتیوانی', '${_user?['support_given'] ?? 0}',
                    Icons.thumb_up),
              ],
            ),
            const SizedBox(height: 24),
            // زانیاریەکان
            _infoTile(Icons.phone, 'تەلەفۆن', _user?['phone'] ?? '-'),
            _infoTile(Icons.calendar_today, 'تۆمارکردن',
                _user?['created_at']?.substring(0, 10) ?? '-'),
            _infoTile(Icons.verified_user, 'رۆڵ', _user?['role'] ?? 'CITIZEN'),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1976D2), size: 28),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1976D2)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
