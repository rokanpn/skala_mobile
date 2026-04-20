import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage/secure_storage.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // چاوەڕوانی ٢ چرکە بۆ نمایشکردنی splash screen
    await Future.delayed(const Duration(seconds: 2));

    // پشکنینی تۆکێن لە هەردوو شوێن (بۆ پشتگیری کۆدە کۆن و نوێکان)
    String? token;

    // یەکەم: لە SecureStorage بگەڕێ (ئاسایشتر)
    try {
      token = await SecureStorage.getAccessToken();
    } catch (e) {
      debugPrint("Error reading from SecureStorage: $e");
    }

    // ئەگەر تۆکێن نەدۆزرایەوە، لە SharedPreferences بگەڕێ (بۆ پشتگیری کۆن)
    if (token == null || token.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString("token");
      } catch (e) {
        debugPrint("Error reading from SharedPreferences: $e");
      }
    }

    // پشکنینی mounted پێش گواستنەوە
    if (!mounted) return;

    // گواستنەوە بۆ لاپەڕەی گونجاو
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => (token != null && token.isNotEmpty)
            ? const HomeScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1976D2), // ڕەنگی شینی جوان
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ئایکۆنی شێوەدار
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_city,
                color: Color(0xFF1976D2),
                size: 60,
              ),
            ),
            const SizedBox(height: 24),

            // ناوی ئەپڵیکەیشن
            const Text(
              'سکاڵا',
              style: TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // وەسف (هاوبەش لە نێوان هەردوو کۆددا)
            const Text(
              'Smart City Platform',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 48),

            // loading indicator
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
