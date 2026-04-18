import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    _check();
  }

  Future<void> _check() async {
    // ✅ const زیاد کرا بۆ Duration
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();

    // ✅ mounted پشکنین
    if (!mounted) return;

    final token = prefs.getString("token");

    // ✅ const زیاد کرا بۆ MaterialPageRoute و widgetەکان
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => (token != null && token.isNotEmpty)
            ? const HomeScreen() // ✅ const زیاد کرا
            : const LoginScreen(), // ✅ const زیاد کرا
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // ✅ const زیاد کرا
      backgroundColor: Colors.amber,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_rounded, size: 90, color: Colors.white),
            SizedBox(height: 16), // ✅ const لەسەرەوە هەیە
            Text(
              "سکاڵا",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Smart City Platform",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 48), // ✅ const لەسەرەوە هەیە
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
