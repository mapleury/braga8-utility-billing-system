import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Title - Bold & Putih Full
  static const TextStyle title = TextStyle(
    fontFamily: 'SFUIDisplay',
    fontWeight: FontWeight.w600, // Bold
    color: AppColors.whiteFull,
    fontSize: 24,
  );

  // Subtitle - Medium & Putih 60%
  static final TextStyle subtitle = TextStyle(
    fontFamily: 'SFUIDisplay',
    fontWeight: FontWeight.w400, // Medium
    color: AppColors.white60,
    fontSize: 16,
  );

  // Body/Caption - Regular & Putih 40%
  static final TextStyle caption = TextStyle(
    fontFamily: 'SFUIDisplay',
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.white40,
    fontSize: 14,
  );
}