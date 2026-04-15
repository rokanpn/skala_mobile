import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    await Future.delayed(Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => (token != null && token.isNotEmpty)
            ? HomeScreen()
            : LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_rounded, size: 90, color: Colors.white),
            SizedBox(height: 16),
            Text("سکاڵا",
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text("Smart City Platform",
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            SizedBox(height: 48),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}