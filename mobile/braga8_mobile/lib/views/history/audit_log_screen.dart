import 'package:braga8_mobile/ApiService.dart';
import 'dart:async';
import 'package:braga8_mobile/data/models/audit_log_model.dart';
import 'package:braga8_mobile/views/core/app_colors.dart';
import 'package:braga8_mobile/views/history/components/pop_up_detail.dart';
import 'package:braga8_mobile/views/widgets/app_header.dart';
import 'package:braga8_mobile/views/widgets/custom_search_bar.dart';
import 'package:braga8_mobile/views/widgets/main_layouts.dart';
import 'package:braga8_mobile/views/widgets/page_header.dart';
import 'package:braga8_mobile/views/widgets/table_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AuditLogScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const AuditLogScreen({super.key, this.onBack});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final ApiService _apiService = ApiService();
  Timer? _refreshTimer;

  int _perPage = 10;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;

  List<AuditLog> _logs = [];
  List<Map<String, dynamic>> _filteredLogs = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      final res = await _apiService.fetchLogs(_currentPage);

      _perPage = res.perPage;
      _logs = res.data;
      _lastPage = res.lastPage;

      _applyFilter(_searchController.text);
    } catch (e) {
      _logs = [];
      _filteredLogs = [];
    }

    setState(() => _isLoading = false);
  }

  void _applyFilter(String query) {
    List<Map<String, dynamic>> mapped = _logs.asMap().entries.map((entry) {
      int index = entry.key;
      AuditLog log = entry.value;

      return {
        "no": "${((_currentPage - 1) * _perPage) + index + 1}",
        "activity": log.description,
        "done_at": DateFormat(
          'dd MMM yyyy, HH:mm',
        ).format(DateTime.parse(log.createdAt)),
      };
    }).toList();

    if (query.isEmpty) {
      _filteredLogs = mapped;
    } else {
      final search = query.toLowerCase();

      _filteredLogs = mapped.where((item) {
        final activity = item['activity'].toLowerCase();
        return activity.contains(search);
      }).toList();
    }

    setState(() {});
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _lastPage) {
      _currentPage++;
      _fetchData();
    }
  }

  void _prevPage() {
    if (_currentPage > 1) {
      _currentPage--;
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainLayout(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                AppHeader(
                  title: "Log Aktivitas",
                  titleIcon: Icons.history_rounded,
                  onBack: widget.onBack,
                  trailing: GestureDetector(
                    onTap: () => _fetchData(), // your reload function
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
                const SizedBox(height: 16),

                const PageHeader(
                  title: "Tabel Aktivitas",
                  subtitle: "Braga8 Activity Tracking System",
                ),

                const SizedBox(height: 30),

                CustomSearchBar(
                  controller: _searchController,
                  hintText: "Cari Nama atau Aktivitas...",
                  onChanged: _applyFilter,
                  onSearchPressed: () => _applyFilter(_searchController.text),
                ),

                const SizedBox(height: 30),

                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  )
                else if (_filteredLogs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        "Data tidak ditemukan",
                        style: TextStyle(color: Colors.white24),
                      ),
                    ),
                  )
                else
                  TableCard(
                    main: "Riwayat Aktivitas",
                    columnWidths: const {
                      0: FixedColumnWidth(40),
                      1: FlexColumnWidth(1),
                    },
                    showUnitCount: false,
                    columns: const ["No", "Aktivitas", "Waktu"],
                    data: _filteredLogs,
                    onRowTap: (item) {
                      PopUpDetail.showDetail(
                        context: context,
                        title: "Detail Aktivitas",
                        infoData: [
                          {"label": "Aktivitas", "value": item['activity']},
                          {"label": "Waktu", "value": item['done_at']},
                        ],
                      );
                    },
                    rowBuilder: (item) => [
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          item['no'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item['activity'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item['done_at'],
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _currentPage > 1 ? _prevPage : null,
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Halaman $_currentPage dari $_lastPage",
                      style: const TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      onPressed: _currentPage < _lastPage ? _nextPage : null,
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
