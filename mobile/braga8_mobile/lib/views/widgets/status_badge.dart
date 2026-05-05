import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final bool isChecked;

  const StatusBadge({super.key, required this.isChecked});

  @override
  Widget build(BuildContext context) {
    final color = isChecked ? const Color(0xFF4CAF50) : const Color(0xFFE57373);
    final label = isChecked ? "Checked" : "Unchecked";
    final icon = isChecked ? Icons.check_circle : Icons.error;

    return SizedBox(
      width:
          110, 
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(13), 
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 0.8, 
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
