import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // دڵنیابوونەوە لەوەی هەموو نیشتیمانەکانی فلاتەر ئامادەن پێش کارپێکردنی SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("token");

  // پشکنینی ئەوەی ئایا بەکارهێنەر پێشتر چۆتە ژوورەوە یان نا
  bool loggedIn = token != null && token.isNotEmpty;

  runApp(SkalaApp(isLoggedIn: loggedIn));
}

class SkalaApp extends StatelessWidget {
  final bool isLoggedIn;

  const SkalaApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skala App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // دیاریکردنی ڕەنگی سەرەکی بە شێوەی Material 3
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
        // ئەگەر فۆنتی کوردی (وەک Sans)ت هەیە لێرەدا دەتوانیت جێگیری بکەیت
        fontFamily: 'Sans',
      ),
      // لێرە بڕیار دەدرێت کام لاپەڕە یەکەمجار نیشان بدرێت
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
