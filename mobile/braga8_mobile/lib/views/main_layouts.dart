import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFF141315),
            image: DecorationImage(
              image: AssetImage('assets/app-background.png'),
              fit: BoxFit.cover,
              opacity: 0.8,
            ),
          ),
        ),
        // Isi konten kamu
        child,
      ],
    );
  }
}