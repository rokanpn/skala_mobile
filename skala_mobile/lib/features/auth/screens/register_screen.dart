import 'package:flutter/material.dart';
// دڵنیابە ناونیشانی ئەم دوو فایلەی خوارەوە ڕاستن بەپێی پڕۆژەکەت
// import 'package:skala_mobile/core/api_client.dart';
// import 'package:skala_mobile/core/api_endpoints.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // لێرەدا کۆنتڕۆڵەرەکان پێناسە دەکەین بۆ ئەوەی ئیرۆری Undefined نەمێنێت
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // پێویستە ئەمە لێرە یان لە شوێنێکی گونجاو پێناسە بکەیت
  // final _apiClient = ApiClient();

  @override
  void dispose() {
    // بۆ ئەوەی میمۆری پڕۆژەکە زۆر نەبێت، کۆنتڕۆڵەرەکان دادەخەین
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    try {
      // لێرەدا پێویستە ApiClient و ApiEndpoints ئیمۆپۆرت بکەیت یان لێرە پێناسەی بکەیت
      /*
      final response = await _apiClient.dio.post(
        ApiEndpoints.register,
        data: {
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );
      */
      print("تۆمارکردن سەرکەوتوو بوو: ${_nameController.text}");
    } catch (e) {
      print("هەڵە هەیە: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تۆمارکردن')), // ئەپ بارێک بۆ جوانی
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          // بۆ ئەوەی کاتێک کیبۆردەکە دەکرێتەوە ئیرۆر نەدات
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'ناوت'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'ئیمەیڵ'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'وشەی نهێنی'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _register,
                child: const Text('تۆمارکردن'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
