import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'features/feed/screens/feed_screen.dart';

void main() async {
  // دڵنیابوونەوە لەوەی هەموو نیشتیمانەکانی فلاتەر ئامادەن پێش کارپێکردنی SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase دەستپێکردن
  await Firebase.initializeApp();

  // چاوەڕێی بارکردنی تۆکەن بکە
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("token");

  // پشکنینی ئەوەی ئایا بەکارهێنەر پێشتر چۆتە ژوورەوە یان نا
  final bool isLoggedIn = token != null && token.isNotEmpty;

  runApp(SkalaApp(isLoggedIn: isLoggedIn));
}

class SkalaApp extends StatelessWidget {
  final bool isLoggedIn;

  const SkalaApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // 🔥 Firebase Messaging Setup - لە ناو build دا
    _setupFirebaseMessaging(context);

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
      locale: const Locale('ku', 'IQ'), // زمانی بنەڕەت کوردی

      // 🎨 ڕووکاری پرۆگرام (Theme)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, // ڕەنگی سەرەکی شین
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Sans', // فۆنتی کوردی یان عەرەبی
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

      // 🌙 ڕووکاری تاریک (Dark Mode)
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

      // سیستەمی گۆڕینی ڕووکار بەپێی سیستەم
      themeMode: ThemeMode.system,

      // 🚀 دیاریکردنی لاپەڕەی یەکەم بەپێی دۆخی چوونەژوورەوە
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),

      // ڕێڕەوەکانی لاپەڕەکان (Navigation Routes)
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/feed': (context) => const FeedScreen(),
      },
    );
  }

  // 🔥 فانکشنی جیاواز بۆ Firebase Messaging (لە ناو کلاسدا)
  void _setupFirebaseMessaging(BuildContext context) {
    // گوێگرتن لە پەیامەکانی Firebase Messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // نیشاندانی notification لە ئەپ
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(message.notification?.title ?? ''),
          content: Text(message.notification?.body ?? ''),
        ),
      );
    });
  }
}
