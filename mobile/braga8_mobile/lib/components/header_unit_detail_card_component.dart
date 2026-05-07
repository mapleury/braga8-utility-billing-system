import 'package:flutter/material.dart';

class HeaderUnitDetailCardComponent extends StatelessWidget {
  final String unitNumber;
  final String tenantName;
  final String electricMeter;
  final String waterMeter;
  final String category;
  final VoidCallback onCategoryToggle;

  const HeaderUnitDetailCardComponent({
    super.key,
    required this.unitNumber,
    required this.tenantName,
    required this.electricMeter,
    required this.waterMeter,
    required this.category,
    required this.onCategoryToggle,
  });

  @override
  Widget build(BuildContext context) {
    // This logic ensures the card reflects the database state
    final String activeMeter = category == "Electric" ? electricMeter : waterMeter;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF723CFF), Color(0xFF5A12DE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A12DE).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "UNIT $unitNumber",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              _buildCategoryBadge(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            tenantName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_2, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  activeMeter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'SFUIDisplay',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return GestureDetector(
      onTap: onCategoryToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category == "Electric" ? Icons.bolt : Icons.water_drop,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              category.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
