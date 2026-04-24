import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Penting untuk format ID

class ProgressMeter extends StatelessWidget {
  final int total;
  final int read;

  const ProgressMeter({
    super.key, 
    required this.total, 
    required this.read
  });

  @override
  Widget build(BuildContext context) {
    // Inisialisasi locale Indonesia agar 'MMMM' tidak error
    initializeDateFormatting('id_ID', null);
    
    // Mengambil nama bulan saat ini
    String currentMonth = DateFormat('MMMM', 'id_ID').format(DateTime.now());

    // Perhitungan persentase
    double percentage = total > 0 ? (read / total) : 0.0;
    
    // Limit agar bar tidak meluap jika input > total
    double displayPercentage = percentage > 1.0 ? 1.0 : percentage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Progress $currentMonth",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$read / $total Meter",
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar Area
          Stack(
            children: [
              // Background Track (Abu-abu)
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Progress Fill (Gradient Indigo/Green)
              FractionallySizedBox(
                widthFactor: displayPercentage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: percentage >= 1.0
                          ? [Colors.green.shade400, Colors.green.shade700]
                          : [Colors.indigo.shade300, Colors.indigo.shade600],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Status Text & Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${(percentage * 100).toStringAsFixed(1)}% Terinput",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              if (percentage >= 1.0)
                const Row(
                  children: [
                    Text(
                      "Selesai",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}