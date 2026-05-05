import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const PageHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title, 
          style: AppTextStyles.title.copyWith(fontSize: 28),
        ),
        SizedBox(height: 4),
        Text(
          subtitle, 
          style: AppTextStyles.subtitle,
        ),
      ],
    );
  }
}