import 'package:braga8_mobile/views/main_layouts.dart';
import 'package:braga8_mobile/views/sign_in_screen.dart';
import 'package:braga8_mobile/views/widgets/light_brown_btn%20copy.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isLoading = false;

  void _handleGetStarted() {
    setState(() {
      _isLoading = true;
    });
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color(0xFF121212);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: MainLayout(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                '../../../assets/onboarding-img.png',
                fit: BoxFit.cover,
                alignment: Alignment(0, -0.2),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      backgroundColor.withValues(alpha: 0.0),
                      backgroundColor.withValues(alpha: 0.2),
                      backgroundColor.withValues(alpha: 0.4),
                      backgroundColor,
                    ],
                    stops: [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Spacer(flex: 8),
                    Image.asset('../../../assets/small-logo.png', height: 22),
                    SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                        children: [
                          TextSpan(
                            text: 'Utilities, ',
                            style: TextStyle(color: Color(0xFF9E9E9E)),
                          ),
                          TextSpan(
                            text: 'Simplified.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'From real-time monitoring to seamless payments. Managing Braga8 utilities has never been this easy.',
                      style: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 35),
                    LightBrownBtn(
                      label: "Get Started",
                      onTap: _handleGetStarted,
                      isLoading: _isLoading,
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
