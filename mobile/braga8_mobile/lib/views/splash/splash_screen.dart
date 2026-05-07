import 'package:braga8_mobile/views/widgets/main_layouts.dart';
import 'package:flutter/material.dart';
import 'dart:async';
// Note: Ensure MainLayout is imported correctly if you use it for the background

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
    debugPrint('✅ SplashScreen mounted');

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _opacity = 1.0);
    });

    Future.delayed(const Duration(seconds: 3), () {
      debugPrint('⏱️ Timer fired, navigating to onboarding');
      if (mounted) Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.black26,
      body: MainLayout(
        child: Stack(
          children: [
            Center(
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: Duration(milliseconds: 1500),
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
