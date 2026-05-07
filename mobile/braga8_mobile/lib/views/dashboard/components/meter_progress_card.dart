import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:braga8_mobile/views/core/app_colors.dart';
import 'package:braga8_mobile/views/core/app_theme.dart';

class MeterProgressCard extends StatelessWidget {
  final int total;
  final int read;
  final String period;

  const MeterProgressCard({
    super.key,
    required this.total,
    required this.read,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final double progressValue = (total > 0) ? (read / total) : 0.0;
    final int percentageText = (progressValue * 100).toInt();
    final int remaining = total - read;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
       border: Border.all(color: AppColors.white40.withOpacity(0.6), width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // ── Background Image ──────────────────────────────────────────
            Positioned.fill(
             
                child: Image.asset(
                  'assets/images/progress-bg.png',
                  fit: BoxFit.cover,
         
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Progress Baca Meter",
                        style: AppTextStyles.subtitle.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      // ── Glassmorphism Badge ──────────────────────────────
                      _buildPeriodBadge(),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Progress Stats ────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$read',
                        style: AppTextStyles.title.copyWith(
                          fontSize: 36,
                          height: 1,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '/ $total Unit tercatat',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white70,
                            fontSize: 17,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Modern Progress Bar ──────────────────────────────────
                  _buildProgressBar(progressValue),
                  const SizedBox(height: 12),

                  // ── Footer Info ──────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusLabel("$percentageText% Selesai"),
                      if (remaining > 0)
                        Text(
                          "$remaining Unit Tersisa",
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white60,
                            fontStyle: FontStyle.normal,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodBadge() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryOrange.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            period,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double value) {
    return Container(
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white40.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryOrange,
                AppColors.primaryOrange.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              // ── The Drop Shadow / Glow ──
              BoxShadow(
                color: AppColors.primaryOrange.withOpacity(
                  0.6,
                ), // Increased opacity
                blurRadius: 12,
                spreadRadius: 1, // Makes the shadow slightly larger
                offset: const Offset(0, 4), // Moves shadow downwards
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusLabel(String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.primaryOrange,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.white60,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
