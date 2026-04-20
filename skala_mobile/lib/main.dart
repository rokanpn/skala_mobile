import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'features/feed/screens/feed_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // چاوەڕێی دۆخەی login بکە بەڵام بێ پەڕەی splash
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  final bool isLoggedIn = token != null && token.isNotEmpty;

  runApp(SkalaApp(isLoggedIn: isLoggedIn));
}

class SkalaApp extends StatelessWidget {
  final bool isLoggedIn;

  const SkalaApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سکاڵا - Skala',
      debugShowCheckedModeBanner: false,

      // 🌐 پشتگیری زمانەکان (RTL & LTR)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ku', 'IQ'), // کوردی - عێراق
        Locale('ar', 'IQ'), // عەرەبی - عێراق
        Locale('en', 'US'), // ئینگلیزی - ئەمریکا
      ],
      locale: const Locale('ku', 'IQ'),

      // 🎨 ڕووکاری پرۆگرام (تێکەڵکردنی هەردوو Theme)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'sans-serif',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),

      themeMode: ThemeMode.system,

      // بەپێی دۆخەی login، پەڕەی یەکەم دیاری بکە
      home: isLoggedIn ? const HomeScreen() : const SplashScreen(),

      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/feed': (context) => const FeedScreen(),
      },
    );
  }
}
