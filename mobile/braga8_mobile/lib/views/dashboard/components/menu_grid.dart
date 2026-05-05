import 'package:braga8_mobile/views/core/app_colors.dart';
import 'package:braga8_mobile/views/core/app_theme.dart';
import 'package:flutter/material.dart';

class MenuGrid extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  final double height;

  const MenuGrid({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
    this.height = 160
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.primaryOrange.withAlpha(4), 
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.white40, width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -70,
                bottom: -80,
                child: Image.asset(
                  imagePath,
                  width: 240, 
                  fit: BoxFit.contain,
                ),
              ),

              // Judul Menu
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  title,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.whiteFull,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}