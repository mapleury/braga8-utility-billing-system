import 'dart:ui';

import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/data/models/complaint_model.dart';
import 'package:braga8_mobile/views/complaint/input_complaint_screen.dart';
import 'package:braga8_mobile/views/core/app_colors.dart';

import 'package:braga8_mobile/views/widgets/app_header.dart';
import 'package:braga8_mobile/views/widgets/custom_search_bar.dart';
import 'package:braga8_mobile/views/widgets/main_layouts.dart';
import 'package:braga8_mobile/views/widgets/page_header.dart';
import 'package:braga8_mobile/views/widgets/table_card.dart';
import 'package:flutter/material.dart';

class CustomerCareListScreen extends StatefulWidget {
  final ApiService api;
  final VoidCallback? onBack;

  const CustomerCareListScreen({super.key, required this.api, this.onBack});

  @override
  State<CustomerCareListScreen> createState() => _CustomerCareListScreenState();
}

class _CustomerCareListScreenState extends State<CustomerCareListScreen>
    with WidgetsBindingObserver {
  late Future<List<Complaint>> _complaintData;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _statusFilter = 'all';

  // ── Colors (mirrors InputReadingScreen) ──────────────────────────────────────
  static const _orange = AppColors.primaryOrange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadData();
  }

  void _loadData() {
    setState(() {
      _complaintData = widget.api.fetchComplaints();
    });
  }

  // ── Filter ───────────────────────────────────────────────────────────────────
  List<Complaint> _getFiltered(List<Complaint> all) {
    return all.where((c) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!c.title.toLowerCase().contains(q) &&
            !c.description.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_statusFilter != 'all' && c.status != _statusFilter) return false;
      return true;
    }).toList();
  }

  // ── Delete ───────────────────────────────────────────────────────────────────
  Future<void> _deleteComplaint(Complaint complaint) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1C1A1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Hapus Komplain",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          content: Text(
            "Yakin ingin menghapus komplain \"${complaint.title}\"?",
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.white38),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                "Hapus",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirm != true) return;

    try {
      await widget.api.deleteComplaint(complaint.id);
      _loadData();
      if (mounted) _showSnack("Komplain berhasil dihapus");
    } catch (e) {
      if (mounted)
        _showSnack(e.toString().replaceFirst("Exception: ", ""), isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isError
                      ? Colors.redAccent.withOpacity(0.5)
                      : _orange.withOpacity(0.5),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isError
                          ? Colors.redAccent.withOpacity(0.15)
                          : _orange.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isError
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      color: isError ? Colors.redAccent : _orange,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      msg,
                      style: TextStyle(
                        color: isError ? Colors.redAccent : Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Filter Bottom Sheet ───────────────────────────────────────────────────────
  void _showFilterModal() {
    String tempStatus = _statusFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter Pencarian",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            setSheetState(() => tempStatus = 'all'),
                        child: const Text(
                          "Reset",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Status Komplain",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _filterChip(
                        label: "Semua",
                        isSelected: tempStatus == 'all',
                        onTap: () => setSheetState(() => tempStatus = 'all'),
                      ),
                      _filterChip(
                        label: "Belum Di Cek",
                        isSelected: tempStatus == 'pending',
                        onTap: () =>
                            setSheetState(() => tempStatus = 'pending'),
                      ),
                      _filterChip(
                        label: "Lagi Diproses",
                        isSelected: tempStatus == 'in_progress',
                        onTap: () =>
                            setSheetState(() => tempStatus = 'in_progress'),
                      ),
                      _filterChip(
                        label: "Sudah Solusi",
                        isSelected: tempStatus == 'resolved',
                        onTap: () =>
                            setSheetState(() => tempStatus = 'resolved'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _statusFilter = tempStatus);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _orange.withOpacity(0.3),
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 0.9,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Terapkan Filter",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Active filter chips ──────────────────────────────────────────────────────
  Widget _buildActiveFilterBar() {
    if (_statusFilter == 'all') return const SizedBox.shrink();
    final label = _statusLabelText(_statusFilter);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: _activeChip(label, () => setState(() => _statusFilter = 'all')),
    );
  }

  Widget _activeChip(String label, VoidCallback onRemove) => Container(
    padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
    decoration: BoxDecoration(
      color: _orange.withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _orange.withOpacity(0.3), width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.close, size: 16, color: Colors.orange),
        ),
      ],
    ),
  );

  Widget _filterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? _orange.withOpacity(0.25)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? _orange.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? _orange.withOpacity(0.9) : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
      ),
    ),
  );

  // ── Status Badge ─────────────────────────────────────────────────────────────
  Widget _complaintStatusBadge(String status) {
    final config = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.border, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            config.label,
            style: TextStyle(
              color: config.text,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _statusConfig(String status) {
    switch (status) {
      case 'in_progress':
        return _StatusConfig(
          label: "Lagi Diproses",
          bg: Colors.blue.withOpacity(0.15),
          border: Colors.blue.withOpacity(0.4),
          dot: Colors.blueAccent,
          text: Colors.blueAccent,
        );
      case 'resolved':
        return _StatusConfig(
          label: "Sudah Solusi",
          bg: Colors.green.withOpacity(0.15),
          border: Colors.green.withOpacity(0.4),
          dot: Colors.greenAccent,
          text: Colors.greenAccent,
        );
      case 'rejected':
        return _StatusConfig(
          label: "Ditolak",
          bg: Colors.red.withOpacity(0.15),
          border: Colors.red.withOpacity(0.4),
          dot: Colors.redAccent,
          text: Colors.redAccent,
        );
      default: // pending
        return _StatusConfig(
          label: "Belum Di Cek",
          bg: Colors.orange.withOpacity(0.15),
          border: Colors.orange.withOpacity(0.4),
          dot: Colors.orangeAccent,
          text: Colors.orangeAccent,
        );
    }
  }

  String _statusLabelText(String status) {
    switch (status) {
      case 'in_progress':
        return "Lagi Diproses";
      case 'resolved':
        return "Sudah Solusi";
      case 'rejected':
        return "Ditolak";
      default:
        return "Belum Di Cek";
    }
  }

  // ── FAB / Add button ─────────────────────────────────────────────────────────
  Widget _buildFab() => Positioned(
    bottom: 28,
    right: 0,
    child: GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => InputComplaintScreen(onBack: () {})),
      ).then((_) => _loadData()),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _orange.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.9),
          boxShadow: [
            BoxShadow(
              color: _orange.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              "Buat Komplain",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  // ── BUILD ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainLayout(
        child: SafeArea(
          bottom: false,
          child: FutureBuilder<List<Complaint>>(
            future: _complaintData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryOrange,
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Gagal memuat data: ${snapshot.error}",
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }

              final all = snapshot.data ?? [];
              final filtered = _getFiltered(all);

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),

                        AppHeader(
                          title: "Customer Care",
                          titleIcon: Icons.support_agent_rounded,
                          onBack: widget.onBack,
                        ),

                        const SizedBox(height: 16),
                        const PageHeader(
                          title: "Customer Care",
                          subtitle: "Braga8 Complaint Management",
                        ),
                        const SizedBox(height: 30),

                        // Search + Filter row
                        Row(
                          children: [
                            Expanded(
                              child: CustomSearchBar(
                                controller: _searchController,
                                hintText: "Cari komplain...",
                                onChanged: (v) =>
                                    setState(() => _searchQuery = v),
                                onSearchPressed: () => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: _showFilterModal,
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: _orange.withOpacity(0.3),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 0.8,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.tune,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        _buildActiveFilterBar(),

                        if (filtered.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Text(
                                "Data tidak ditemukan",
                                style: TextStyle(color: Colors.white38),
                              ),
                            ),
                          )
                        else
                          TableCard(
                            prefix: "Komplain",
                            suffixText: "${filtered.length} Item",
                            main: "Daftar Komplain",
                            columnWidths: const {
                              0: FlexColumnWidth(2.0), // Judul
                              1: FlexColumnWidth(2.2), // Keterangan
                              2: FlexColumnWidth(1.8), // Status
                              3: FlexColumnWidth(1.6), // Aksi
                            },
                            columns: const [
                              "Judul",
                              "Keterangan",
                              "Status",
                              "Aksi",
                            ],
                            data: filtered.map((c) => {'object': c}).toList(),
                            rowBuilder: (item) {
                              final c = item['object'] as Complaint;
                              return [
                                // ── Judul ─────────────────────────────────
                                Text(
                                  c.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                // ── Keterangan (truncated) ────────────────
                                Text(
                                  c.description,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                // ── Status Badge ──────────────────────────
                                _complaintStatusBadge(c.status),

                                // ── Action buttons ────────────────────────
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Edit
                                    _actionBtn(
                                      icon: Icons.edit_rounded,
                                      color: Colors.blueAccent,
                                      tooltip: "Edit",
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => InputComplaintScreen(
                                            complaint: c,
                                            isEdit: true,
                                            onBack: () {},
                                          ),
                                        ),
                                      ).then((_) => _loadData()),
                                    ),
                                    const SizedBox(width: 8),
                                    // Delete
                                    _actionBtn(
                                      icon: Icons.delete_rounded,
                                      color: Colors.redAccent,
                                      tooltip: "Hapus",
                                      onTap: () => _deleteComplaint(c),
                                    ),
                                  ],
                                ),
                              ];
                            },
                          ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),

                  // FAB — Buat Komplain
                  _buildFab(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) => Tooltip(
    message: tooltip,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.35), width: 1),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    ),
  );
}

// ── Status config helper ──────────────────────────────────────────────────────
class _StatusConfig {
  final String label;
  final Color bg;
  final Color border;
  final Color dot;
  final Color text;

  const _StatusConfig({
    required this.label,
    required this.bg,
    required this.border,
    required this.dot,
    required this.text,
  });
}
