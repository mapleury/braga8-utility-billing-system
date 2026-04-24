import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImageDetailCardComponent extends StatelessWidget {
  final String? inputDate;
  final String? location;
  final String category; // Tambahkan category (Electric/Water)

  const ImageDetailCardComponent({
    super.key,
    required this.inputDate,
    required this.location,
    required this.category, // Wajib diisi
  });

  // Helper: Format Bulan Tagihan (Contoh: April 2026)
  String _formatBillingMonth(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      DateTime dateTime = DateTime.parse(dateStr);
      // Biasanya billing month adalah bulan dari recorded_at
      return DateFormat('MMMM yyyy').format(dateTime);
    } catch (e) {
      return "Current Period";
    }
  }

  // Helper: Format Tanggal Lengkap (Contoh: 20 Apr 2026, 08:13)
  String _formatFullDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Not Recorded";
    try {
      DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Billing Month
          _buildInfoRow(
            Icons.calendar_month_rounded,
            "Billing Month",
            _formatBillingMonth(inputDate),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(height: 24, thickness: 0.8, color: Color(0xFFF1F1F1)),
          ),

          // Row 2: Input Date
          _buildInfoRow(
            Icons.history_rounded,
            "Input Date",
            _formatFullDate(inputDate),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(height: 24, thickness: 0.8, color: Color(0xFFF1F1F1)),
          ),

          // Row 3: Dynamic Location Label berdasarkan Category
          _buildInfoRow(
            Icons.location_on_rounded,
            "$category Location", // Menjadi "Electric Location" atau "Water Location"
            location ?? "-",
            isMultiLine: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value, {
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiLine
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF723CFF)),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF1A1A1A),
            ),
            softWrap: true,
            maxLines: isMultiLine ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}