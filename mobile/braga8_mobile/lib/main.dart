import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/views/routes/app_router.dart';
import 'package:flutter/material.dart';

final ApiService apiService = ApiService();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter(apiService);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Braga 8 System',
      theme: ThemeData(fontFamily: 'SFUIDisplay'),
      initialRoute: '/',
      onGenerateRoute: router.onGenerateRoute,
    );
  }
}
