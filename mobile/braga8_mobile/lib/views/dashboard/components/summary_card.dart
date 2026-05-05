import 'package:braga8_mobile/views/core/app_colors.dart';
import 'package:braga8_mobile/views/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryCard extends StatelessWidget {
  final double currentValue; 
  final double targetValue;  
  final String period;

  const SummaryCard({
    super.key,
    required this.currentValue,
    required this.targetValue,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    double progressValue = (targetValue > 0) ? (currentValue / targetValue) : 0.0;
    int percentageText = (progressValue * 100).toInt();
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withAlpha(4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white40, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tagihan Bulan Ini", style: AppTextStyles.subtitle),
              Text(period, style: AppTextStyles.caption.copyWith(color: AppColors.primaryOrange)),
            ],
          ),
          SizedBox(height: 12),
          
          Text(
            formatter.format(currentValue),
            style: AppTextStyles.title.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryOrange,
            ),
          ),
          
          SizedBox(height: 16),

          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white40,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progressValue.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "$percentageText% dari target", // Tetap informatif tapi bersih
            style: AppTextStyles.caption.copyWith(color: AppColors.white60),
          ),
        ],
      ),
    );
  }
}