import 'package:braga8_mobile/views/core/app_colors.dart';
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final IconData? titleIcon;
  final String backLabel;
  final VoidCallback? onBack;
  final Widget? trailing;

  const AppHeader({
    super.key,
    required this.title,
    this.titleIcon,
    this.backLabel = "Kembali",
    this.onBack,
    this.trailing,
  });

  static Color get _glassBorder => Colors.white.withOpacity(0.12);

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Increased bottom margin as requested earlier for a cleaner look
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        // This is the magic line that spreads the items evenly
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── 1. Back Pill ──
          GestureDetector(
            onTap: onBack ?? () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _glassBorder, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    backLabel,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 2. Title (No Container, White Color) ──
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (titleIcon != null) ...[
                Icon(titleIcon, color: Colors.white30, size: 16),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // ── 3. Trailing ──
          // We wrap this in a SizedBox to ensure it takes up space even if null
          // This keeps the Title perfectly centered.
          SizedBox(
            child: trailing ??
                Opacity(
                  opacity: 0,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Text(backLabel, style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}