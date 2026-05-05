import 'package:flutter/material.dart';

class GradientBorderBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color buttonColor;
  final IconData? icon;

  const GradientBorderBtn({
    super.key,
    required this.label,
    required this.onTap,
    required this.buttonColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // Gradient Border
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.white.withValues(alpha: 0.6),
              Colors.white.withValues(alpha: 0.05),
              Colors.white.withValues(alpha: 0.6),
            ],
          ),
        ),
        padding: EdgeInsets.all(1.5), // Tebal border
        child: Container(
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(11), // Radius lebih kecil dari container luar
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}