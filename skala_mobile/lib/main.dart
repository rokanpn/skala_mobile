import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'features/feed/screens/feed_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("token");
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

      // 🌐 پشتگیری زمانەکان (RTL & LTR) - ڕێکخستنی تەواو
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

      // 🎨 ڕووکاری پرۆگرام
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Sans',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Sans',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),

      themeMode: ThemeMode.system,

      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/feed': (context) => const FeedScreen(),
      },
    );
  }
}
