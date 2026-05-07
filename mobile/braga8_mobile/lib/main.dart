import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/views/dashboard/dashboard_screen.dart';
import 'package:braga8_mobile/views/onboarding_screen.dart';
import 'package:braga8_mobile/views/sign_in_screen.dart';
import 'package:braga8_mobile/views/splash/splash_screen.dart';
import 'package:flutter/material.dart';

final ApiService apiService = ApiService();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Braga 8 System',
      theme: ThemeData(fontFamily: 'SFUIDisplay'),

      home: const SplashScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const SignInScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => DashboardScreen(
              api: apiService,
              token: args['token'],
              role: args['role'],
            ),
          );
        }
        return null;
      },
    );
  }
}
