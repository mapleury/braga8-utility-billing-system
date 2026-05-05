import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/data/models/meter_reading_model.dart';

class MeterHistoryScreen extends StatefulWidget {
  final int unitId;
  final String unitNumber;

  const MeterHistoryScreen({
    super.key,
    required this.unitId,
    required this.unitNumber,
  });

  @override
  State<MeterHistoryScreen> createState() => _MeterHistoryScreenState();
}

class _MeterHistoryScreenState extends State<MeterHistoryScreen> {
  static const String _apiImageUrl =
      "https://bunkbed-deem-spew.ngrok-free.dev/api/meter-photo/";
  static const Color _purple = Color(0xFF723CFF);

  final ApiService _apiService = ApiService();
  late Future<List<MeterReadingHistory>> _futureHistory;

  // Filter state
  String _selectedFilter = "All"; // "All", "Electric", "Water"

  @override
  void initState() {
    super.initState();
    _futureHistory = _apiService.fetchReadingHistory(widget.unitId);
  }

  String _formatDate(String? raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String _formatMonth(String? raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('MMMM yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String? _buildPhotoUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    return "$_apiImageUrl${path.split('/').last}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(
          "Riwayat - Unit ${widget.unitNumber}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: FutureBuilder<List<MeterReadingHistory>>(
              future: _futureHistory,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _purple),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 60, color: Colors.red.shade300),
                        const SizedBox(height: 12),
                        const Text("Gagal memuat riwayat"),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() {
                            _futureHistory = _apiService
                                .fetchReadingHistory(widget.unitId);
                          }),
                          child: const Text("Coba Lagi"),
                        ),
                      ],
                    ),
                  );
                }

                final allData = snapshot.data ?? [];
                final filtered = _selectedFilter == "All"
                    ? allData
                    : allData
                        .where((r) =>
                            _selectedFilter == "Electric"
                                ? r.isElectric
                                : !r.isElectric)
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history,
                            size: 70, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          "Belum Ada Riwayat",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Group by bulan
                final grouped = <String, List<MeterReadingHistory>>{};
                for (final r in filtered) {
                  final key = _formatMonth(r.recordedAt);
                  grouped.putIfAbsent(key, () => []).add(r);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final monthKey = grouped.keys.elementAt(index);
                    final readings = grouped[monthKey]!;
                    return _buildMonthGroup(monthKey, readings);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: ["All", "Electric", "Water"].map((label) {
          final isActive = _selectedFilter == label;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isActive,
              onSelected: (_) => setState(() => _selectedFilter = label),
              selectedColor: _purple,
              labelStyle: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthGroup(
      String month, List<MeterReadingHistory> readings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
          child: Text(
            month,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...readings.map((r) => _buildReadingCard(r)),
      ],
    );
  }

  Widget _buildReadingCard(MeterReadingHistory r) {
    final photoUrl = _buildPhotoUrl(r.photoPath);
    final isElec = r.isElectric;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: photoUrl != null
                  ? Image.network(
                      photoUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      headers: const {
                        'ngrok-skip-browser-warning': 'true',
                      },
                      errorBuilder: (_, __, ___) => _photoPlaceholder(),
                    )
                  : _photoPlaceholder(),
            ),

            const SizedBox(width: 14),

            // Info utama
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge tipe + status
                  Row(
                    children: [
                      _buildBadge(
                        isElec ? "⚡ Electric" : "💧 Water",
                        isElec
                            ? const Color(0xFFFFF3CD)
                            : const Color(0xFFD1ECF1),
                        isElec
                            ? const Color(0xFF856404)
                            : const Color(0xFF0C5460),
                      ),
                      const SizedBox(width: 6),
                      if (r.isChecked)
                        _buildBadge(
                          "✓ Verified",
                          const Color(0xFFD4EDDA),
                          const Color(0xFF155724),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Nilai reading
                  Text(
                    isElec
                        ? "${r.readingValue} kWh"
                        : "${r.readingValue} m³",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _purple,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Tanggal
                  Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 13, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(r.recordedAt),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),

                  // Nomor meter
                  if (r.meterNumber != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.speed,
                            size: 13, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          r.meterNumber!,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],

                  // Lokasi
                  if (r.locationAddress != null &&
                      r.locationAddress!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 13, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            r.locationAddress!,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      width: 64,
      height: 64,
      color: Colors.grey.shade100,
      child: Icon(Icons.image_not_supported_outlined,
          color: Colors.grey.shade400, size: 28),
    );
  }

  Widget _buildBadge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}