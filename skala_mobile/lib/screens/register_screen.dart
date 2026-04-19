import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/secure_storage.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;

  late final ApiClient _apiClient;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // هەوڵی تۆمارکردن بە AuthService (بۆ پشتگیری کۆدی کۆن)
      final result = await AuthService.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
        phoneController.text.trim(),
      );

      if (result != null) {
        // هەوڵی تۆمارکردنی تۆکێن بە SecureStorage
        try {
          final response = await _apiClient.dio.post(
            ApiEndpoints.register,
            data: {
              'name': nameController.text.trim(),
              'email': emailController.text.trim(),
              'phone': phoneController.text.trim(),
              'password': passwordController.text,
            },
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            await SecureStorage.saveTokens(
              accessToken: response.data['access_token'],
              refreshToken: response.data['refresh_token'],
            );
            if (response.data['user'] != null) {
              await SecureStorage.saveUserId(
                  response.data['user']['id'].toString());
            }
          }
        } catch (tokenError) {
          // ئەگەر تۆکێن تۆمار نەکرا، کێشە نییە - بەردەوام بە
          debugPrint("Token storage error: $tokenError");
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "هەڵەیەک هەیە — ئیمەیڵ دووبارە بووە یان داتاکان نادروستن"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        String errorMessage = e.response?.data['message'] ??
            e.response?.data['error'] ??
            'هەڵەیەک ڕووی دا، دووبارە هەوڵ بدەوە';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("هەڵەیەک ڕووی دا: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("تۆمارکردن"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1976D2),
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // لۆگۆ
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.location_city,
                        color: Colors.white, size: 45),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'سکاڵا',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'ئەکاونتی نوێ دروست بکە',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 40),

                // ناوی تەواو
                TextFormField(
                  controller: nameController,
                  textAlign: TextAlign.right,
                  decoration:
                      _inputDecoration('ناوی تەواو', Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ناوەکەت بنووسە';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ئیمەیڵ
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.left,
                  decoration: _inputDecoration('ئیمەیڵ', Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ئیمەیڵەکەت بنووسە';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'ئیمەیڵ دروست نییە';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ژمارەی تەلەفۆن
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.left,
                  decoration:
                      _inputDecoration('ژمارەی تەلەفۆن', Icons.phone_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ژمارەی تەلەفۆنت بنووسە';
                    }
                    if (value.length < 9) {
                      return 'ژمارەی تەلەفۆن نادروستە';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // وشەی نهێنی
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  textAlign: TextAlign.left,
                  decoration: _inputDecoration(
                    'وشەی نهێنی',
                    Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'وشەی نهێنیت بنووسە';
                    }
                    if (value.length < 6) {
                      return 'وشەی نهێنی دەبێت لانی کەم ٦ پیت بێت';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // دوگمەی تۆمارکردن
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "دروستکردنی ئەکاونت",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // چوونەژوورەوە
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ئەکاونتت هەیە؟',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'بچۆ ژوورەوە',
                        style: TextStyle(
                          color: Color(0xFF1976D2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFF1976D2), size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
