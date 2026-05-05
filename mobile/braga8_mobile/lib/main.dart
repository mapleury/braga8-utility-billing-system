import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/views/sign_in_screen.dart';
import 'package:flutter/material.dart';

// Global singleton — satu token untuk seluruh app
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
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF723CFF),
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const SignInScreen(),
      },
    );
  }
}