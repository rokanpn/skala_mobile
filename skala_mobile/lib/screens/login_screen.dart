import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/secure_storage.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  late final ApiClient _apiClient;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
  }

  Future<void> login() async {
    // Form validation
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // Method 1: هەوڵی چوونەژوورەوە بە AuthService (بۆ پشتگیری کۆدە کۆنەکان)
      final result = await AuthService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (result != null && result['success'] == true) {
        // Method 2: هەوڵی تۆمارکردنی تۆکێن بە ApiClient (بۆ سیستەمی نوێ)
        await _saveTokensWithApiClient();

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
              content: Text("ئیمەیڵ یان پاسووردی هەڵەیە"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on DioException catch (e) {
      String errorMessage = 'هەڵەیەک ڕووی دا، دووبارە هەوڵ بدەوە';
      if (e.response?.statusCode == 401) {
        errorMessage = 'ئیمەیڵ یان پاسووردی هەڵەیە';
      } else if (e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }

      if (mounted) {
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

  Future<void> _saveTokensWithApiClient() async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: {
          'email': emailController.text.trim(),
          'password': passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        await SecureStorage.saveTokens(
          accessToken: response.data['access_token'],
          refreshToken: response.data['refresh_token'],
        );
        if (response.data['user'] != null) {
          await SecureStorage.saveUserId(
            response.data['user']['id'].toString(),
          );
        }
      }
    } catch (tokenError) {
      // ئەگەر تۆکێن تۆمار نەکرا، کێشە نییە - بەردەوام بە
      debugPrint("Token storage error: $tokenError");
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // لۆگۆ
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1976D2).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.location_city,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ناوی ئەپڵیکەیشن
                const Center(
                  child: Text(
                    'سکاڵا',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'چوونەژوورەوە بە ئەکاونتەکەت',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 40),

                // فیلدی ئیمەیڵ
                _buildTextField(
                  controller: emailController,
                  label: 'ئیمەیڵ',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
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
                const SizedBox(height: 14),

                // فیلدی وشەی نهێنی
                _buildTextField(
                  controller: passwordController,
                  label: 'وشەی نهێنی',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => login(),
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

                // دوگمەی چوونەژوورەوە
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "چوونەژوورەوە",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // بەستەری تۆمارکردن
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "ئەکاونتت نییە؟ ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: const Text(
                        "تۆمارکردن",
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    void Function(String)? onFieldSubmitted,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.left,
      decoration: InputDecoration(
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
      ),
      validator: validator,
    );
  }
}
