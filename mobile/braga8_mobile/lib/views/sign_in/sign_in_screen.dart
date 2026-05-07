import 'package:braga8_mobile/main.dart'; // for apiService singleton
import 'package:braga8_mobile/services/session_services.dart';
import 'package:braga8_mobile/views/dashboard/dashboard_screen.dart'; // DashboardScreen
import 'package:braga8_mobile/views/widgets/main_layouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;
  bool _isLoading = false;
  bool _isRememberMe = false;
  String? _emailError;
  String? _passwordError;

  final List<Shadow> _uiShadows = [
    Shadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  void _handleLogin() async {
    if (_emailController.text.isEmpty) {
      setState(() => _emailError = "Email tidak boleh kosong");
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = "Password wajib diisi");
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });

    try {
      final response = await apiService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (response != null && response['token'] != null) {
        if (!mounted) return;

        // Add this block
        await SessionService.saveSession(
          token: response['token'],
          role: response['user']['role'] ?? 'petugas',
          name: response['user']['name'] ?? '',
        );

        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
          arguments: {
            'token': response['token'],
            'role': response['user']['role'] ?? 'Petugas',
          },
        );
      } else {
        setState(() => _emailError = "Email atau Password salah.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Koneksi ke server gagal.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: MainLayout(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.88,
              constraints: const BoxConstraints(minHeight: 650),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                image: const DecorationImage(
                  image: AssetImage('assets/sign-in-bg.png'),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.white12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/logo.png', width: 45),
                    const SizedBox(height: 40),
                    Text(
                      "Sign In to Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: _uiShadows,
                      ),
                    ),
                    const SizedBox(height: 35),
                    _buildLabel("Email"),
                    _buildTextField(
                      controller: _emailController,
                      hint: "Enter your email",
                      errorText: _emailError,
                    ),
                    const SizedBox(height: 5),
                    _buildLabel("Password"),
                    _buildTextField(
                      controller: _passwordController,
                      hint: "Enter your password",
                      isPassword: true,
                      isObscured: _isObscured,
                      errorText: _passwordError,
                      onSuffixTap: () =>
                          setState(() => _isObscured = !_isObscured),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRememberMe(),
                        const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    GestureDetector(
                      onTap: _isLoading ? null : _handleLogin,
                      child: SizedBox(
                        width: double.infinity,
                        child: AspectRatio(
                          aspectRatio: 3.6,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned.fill(
                                child: SvgPicture.asset(
                                  'assets/login_btn.svg',
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(0, -6),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        "Log In",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          shadows: _uiShadows,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          shadows: _uiShadows,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    bool isObscured = false,
    String? errorText,
    VoidCallback? onSuffixTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFDCC8BB),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? isObscured : false,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              border: InputBorder.none,
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isObscured ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[700],
                      ),
                      onPressed: onSuffixTap,
                    )
                  : null,
            ),
          ),
        ),
        SizedBox(
          height: 28,
          child: errorText != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 4, top: 4),
                  child: Text(
                    errorText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildRememberMe() {
    return GestureDetector(
      onTap: () => setState(() => _isRememberMe = !_isRememberMe),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: _isRememberMe
                ? const Icon(Icons.check, size: 16, color: Color(0xFF8B5A2B))
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            "Remember me",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              shadows: _uiShadows,
            ),
          ),
        ],
      ),
    );
  }
}
