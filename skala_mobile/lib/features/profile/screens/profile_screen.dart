import 'package:flutter/material.dart';

// وەک نموونە ئەم مۆدێلە لێرە دادەنێم، ئەگەر خۆت مۆدێلی Userت هەیە ئیمۆپۆرتی بکە
class UserModel {
  final String name;
  final int coins;
  UserModel({required this.name, required this.coins});
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // مێثۆدێک بۆ هێنانی زانیارییەکان (وەک نموونە)
  Future<UserModel> _loadProfile() async {
    await Future.delayed(
        const Duration(seconds: 2)); // وەک چاوەڕێکردن بۆ سێرڤەر
    return UserModel(name: "تەوانا تاهیر", coins: 150);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پڕۆفایل')),
      body: FutureBuilder<UserModel>(
        future: _loadProfile(),
        builder: (context, snapshot) {
          // ١. ئەگەر خەریکی لۆدین بوو
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ٢. ئەگەر هەڵەیەک ڕوویدا
          if (snapshot.hasError) {
            return Center(child: Text('هەڵەیەک هەیە: ${snapshot.error}'));
          }

          // ٣. ئەگەر داتاکە بە سەرکەوتوویی گەیشت
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blueGrey,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(user.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // کۆینەکان
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min, // بۆ ئەوەی هەموو پانی شاشەکە نەگرێت
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          '${user.coins} کۆین',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('هیچ داتایەک نییە'));
        },
      ),
    );
  }
}
