import 'package:braga8_mobile/main.dart';
import 'package:braga8_mobile/services/session_services.dart';
import 'package:braga8_mobile/views/widgets/main_layouts.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _opacity = 1.0);
    });

    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;

      final session = await SessionService.getSession();
      if (!mounted) return;

      if (session != null) {
        // Restore ApiService user state from session
        apiService.setCurrentUser({
          'name': session['name'] ?? '',
          'role': session['role'] ?? '',
        });

        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
          arguments: {'token': session['token']!, 'role': session['role']!},
        );
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: MainLayout(
        child: Stack(
          children: [
            Center(
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeIn,
                child: SizedBox(
                  width: 90,
                  child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}
