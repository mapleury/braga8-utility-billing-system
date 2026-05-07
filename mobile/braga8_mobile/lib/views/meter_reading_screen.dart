import 'dart:ui';
import 'package:braga8_mobile/data/models/tenant_model.dart';
import 'package:braga8_mobile/views/input_reading_screen.dart';
import 'package:braga8_mobile/views/widgets/app_header.dart';
import 'package:braga8_mobile/views/widgets/main_layouts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/data/models/meter_reading_model.dart';
import 'package:braga8_mobile/views/core/app_colors.dart';

class MeterHistoryScreen extends StatefulWidget {
  final int unitId;
  final Unit? unit;
  final String unitNumber;
  final VoidCallback? onBack;

  const MeterHistoryScreen({
    super.key,
    required this.unitId,
    required this.unitNumber,
    this.unit,
    this.onBack,
  });

  @override
  State<MeterHistoryScreen> createState() => _MeterHistoryScreenState();
}

class _MeterHistoryScreenState extends State<MeterHistoryScreen>
    with SingleTickerProviderStateMixin {
  static const String _apiImageUrl =
      "https://bunkbed-deem-spew.ngrok-free.dev/api/meter-photo/";
  static const _orange = AppColors.primaryOrange;

  Color get _orangeDim => _orange.withOpacity(0.18);
  Color get _orangeBorder => _orange.withOpacity(0.45);
  Color get _glass => Colors.white.withOpacity(0.05);
  Color get _glassBorder => Colors.white.withOpacity(0.12);

  final ApiService _apiService = ApiService();
  late Future<List<MeterReadingHistory>> _futureHistory;
  String _selectedFilter = "Semua";

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _futureHistory = _apiService.fetchReadingHistory(widget.unitId);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatDate(String? raw) {
    if (raw == null) return '-';
    try {
      return DateFormat(
        'dd MMM yyyy, HH:mm',
      ).format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }

  String _formatMonth(String? raw) {
    if (raw == null) return '-';
    try {
      return DateFormat('MMMM yyyy').format(DateTime.parse(raw).toLocal());
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: MainLayout(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppHeader(
                   
                    title: "Riwayat | Unit ${widget.unitNumber}",
                    titleIcon: Icons.store_rounded,
                    onBack: widget.onBack,
                    trailing: GestureDetector(
                      onTap: _refreshData,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                _buildFilterRow(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "Riwayat Meter | Unit ${widget.unitNumber}",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.black.withOpacity(0.35),
      elevation: 0,
      centerTitle: true,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: Colors.transparent),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _glassBorder),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
      child: Row(
        children: ["Semua", "Listrik", "Air"].map((label) {
          final isActive = _selectedFilter == label;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? _orangeDim : _glass,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? _orangeBorder : _glassBorder,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isActive ? _orange : Colors.white38,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<MeterReadingHistory>>(
      future: _futureHistory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: _orange));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded, size: 60, color: Colors.white24),
                const SizedBox(height: 16),
                const Text(
                  "Gagal memuat riwayat",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(() {
                    _futureHistory = _apiService.fetchReadingHistory(
                      widget.unitId,
                    );
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _orangeDim,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _orangeBorder),
                    ),
                    child: Text(
                      "Coba Lagi",
                      style: TextStyle(
                        color: _orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final allData = snapshot.data ?? [];
        final filtered = _selectedFilter == "Semua"
            ? allData
            : allData
                  .where(
                    (r) => _selectedFilter == "Listrik"
                        ? r.isElectric
                        : !r.isElectric,
                  )
                  .toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _orangeDim,
                    shape: BoxShape.circle,
                    border: Border.all(color: _orangeBorder, width: 1.5),
                  ),
                  child: Icon(Icons.history_rounded, size: 36, color: _orange),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Belum Ada Riwayat",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          );
        }

        // Group by bulan
        final grouped = <String, List<MeterReadingHistory>>{};
        for (final r in filtered) {
          grouped.putIfAbsent(_formatMonth(r.recordedAt), () => []).add(r);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final month = grouped.keys.elementAt(index);
            final readings = grouped[month]!;
            return _buildMonthGroup(month, readings);
          },
        );
      },
    );
  }

  Widget _buildMonthGroup(String month, List<MeterReadingHistory> readings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
          child: Text(
            month.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.3),
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...readings.map((r) => _buildReadingCard(r)),
      ],
    );
  }

  Widget _buildReadingCard(MeterReadingHistory r) {
    final photoUrl = _buildPhotoUrl(r.photoPath);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _glass,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              // ── highlight rejected entries ──
              color: r.status == 'rejected'
                  ? Colors.redAccent.withOpacity(0.5)
                  : _glassBorder,
              width: r.status == 'rejected' ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badges row
                        Row(
                          children: [
                            _buildBadge(r),
                            const SizedBox(width: 6),
                            _buildStatusBadge(r), // ← new
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          r.isElectric
                              ? "${r.readingValue} kWh"
                              : "${r.readingValue} m³",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _orange,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        _metaRow(
                          Icons.schedule_rounded,
                          _formatDate(r.recordedAt),
                        ),
                        if (r.meterNumber != null)
                          _metaRow(Icons.speed_rounded, r.meterNumber!),
                        if (r.locationAddress != null &&
                            r.locationAddress!.isNotEmpty)
                          _metaRow(
                            Icons.location_on_outlined,
                            r.locationAddress!,
                            maxLines: 2,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Rejected: show reason + fix button ──────────────────────
              if (r.status == 'rejected') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Data ditolak admin. Silakan perbaiki dan kirim ulang.",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InputReadingScreen(
                            isEdit: true,
                            initialValue: r.readingValue,
                            unit: widget.unit,
                            category: r.isElectric ? "Electric" : "Water",
                          ),
                        ),
                      );
                      if (result == true) {
                        setState(() {
                          _futureHistory = _apiService.fetchReadingHistory(
                            widget.unitId,
                          );
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.build_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Perbaiki Data",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.25),
                      elevation: 0,
                      side: BorderSide(
                        color: Colors.redAccent.withOpacity(0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaRow(IconData icon, String text, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: Colors.white38),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: Colors.white38),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _glassBorder),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white24,
        size: 26,
      ),
    );
  }

  Widget _buildBadge(MeterReadingHistory r) {
    final isElec = r.isElectric;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isElec
            ? Colors.amber.withOpacity(0.15)
            : Colors.cyan.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isElec
              ? Colors.amber.withOpacity(0.35)
              : Colors.cyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        isElec ? "⚡ Listrik" : "💧 Air",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isElec ? Colors.amber : Colors.cyan,
        ),
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.35), width: 1),
      ),
      child: const Text(
        "✓ Terverifikasi",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MeterReadingHistory r) {
    if (r.status == 'checked') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withOpacity(0.35), width: 1),
        ),
        child: const Text(
          "✓ Terverifikasi",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.green,
          ),
        ),
      );
    } else if (r.status == 'rejected') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.redAccent.withOpacity(0.35),
            width: 1,
          ),
        ),
        child: const Text(
          "✗ Ditolak",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.redAccent,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.withOpacity(0.35), width: 1),
        ),
        child: const Text(
          "⏳ Menunggu",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.orange,
          ),
        ),
      );
    }
  }

  void _refreshData() {
    setState(() {
      _futureHistory = _apiService.fetchReadingHistory(widget.unitId);
    });
    _animController.reset();
    _animController.forward();
  }
}
