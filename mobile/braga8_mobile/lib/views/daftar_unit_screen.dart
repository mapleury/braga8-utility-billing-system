import 'dart:ui';

import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/data/models/tenant_model.dart';
import 'package:braga8_mobile/views/core/app_colors.dart';
import 'package:braga8_mobile/views/detail_unit_screen.dart';
import 'package:braga8_mobile/views/widgets/action_button_table.dart';
import 'package:braga8_mobile/views/widgets/app_header.dart';
import 'package:braga8_mobile/views/widgets/custom_search_bar.dart';
import 'package:braga8_mobile/views/widgets/main_layouts.dart';
import 'package:braga8_mobile/views/widgets/page_header.dart';
import 'package:braga8_mobile/views/widgets/status_badge.dart';
import 'package:braga8_mobile/views/widgets/table_card.dart';
import 'package:flutter/material.dart';

class DaftarUnitScreen extends StatefulWidget {
  final ApiService api;
  final VoidCallback? onBack;
  const DaftarUnitScreen({super.key, required this.api, this.onBack});

  @override
  State<DaftarUnitScreen> createState() => _DaftarUnitScreenState();
}

class _DaftarUnitScreenState extends State<DaftarUnitScreen>
    with WidgetsBindingObserver {
  late Future<List<Tenant>> _tenantData;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  Set<String> _selectedFloors = {};
  String _statusFilter = 'all';

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
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
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  void _loadData() {
    setState(() {
      _tenantData = widget.api.fetchUnitsSummary();
    });
  }
  // -----------------------------------------------------------------------
  // FILTER HELPERS
  // -----------------------------------------------------------------------

  bool _isUnitChecked(dynamic unit) {
    return unit.isElecChecked && unit.isWaterChecked;
  }

  List<String> _allFloors(List<Tenant> tenants) {
    final floors = <String>{};
    for (final t in tenants) {
      for (final u in t.units) {
        if (u.floor.isNotEmpty && u.floor != '-') floors.add(u.floor);
      }
    }
    return floors.toList()..sort();
  }

  List<MapEntry<Tenant, List<dynamic>>> _getFilteredData(List<Tenant> tenants) {
    // Tambahkan [] sebelum kurung tutup terakhir
    final result = <MapEntry<Tenant, List<dynamic>>>[];

    for (final tenant in tenants) {
      final filteredUnits = tenant.units.where((unit) {
        // ... (logika filter kamu tetap sama)
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          if (!tenant.name.toLowerCase().contains(q) &&
              !unit.unitNumber.toLowerCase().contains(q)) {
            return false;
          }
        }
        if (_selectedFloors.isNotEmpty &&
            !_selectedFloors.contains(unit.floor)) {
          return false;
        }
        if (_statusFilter == 'checked' && !_isUnitChecked(unit)) return false;
        if (_statusFilter == 'unchecked' && _isUnitChecked(unit)) return false;
        return true;
      }).toList();

      if (filteredUnits.isNotEmpty) {
        // Sekarang .add dan MapEntry tidak akan merah lagi
        result.add(MapEntry(tenant, filteredUnits));
      }
    }
    return result;
  }

  // -----------------------------------------------------------------------
  // FILTER BOTTOM SHEET
  // -----------------------------------------------------------------------

  void _showFilterModal(List<Tenant> tenants) {
    final floors = _allFloors(tenants);
    Set<String> tempFloors = Set.from(_selectedFloors);
    String tempStatus = _statusFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(0, 60, 60, 60),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ), // Efek Glassmorphism
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              decoration: BoxDecoration(
                // Black soft transparent background
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.15,
                  ), // Apple soft border
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        onPressed: () => setSheetState(() {
                          tempFloors.clear();
                          tempStatus = 'all';
                        }),
                        child: Text(
                          "Reset",
                          style: TextStyle(
                            color: const Color.fromARGB(173, 255, 255, 255),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _sectionHeader("Lantai"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: floors.map((floor) {
                      final isSelected = tempFloors.contains(floor);
                      return _customFilterChip(
                        label: floor,
                        isSelected: isSelected,
                        onTap: () => setSheetState(() {
                          isSelected
                              ? tempFloors.remove(floor)
                              : tempFloors.add(floor);
                        }),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),
                  _sectionHeader("Status Pencatatan"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _customFilterChip(
                        label: 'Semua',
                        isSelected: tempStatus == 'all',
                        onTap: () => setSheetState(() => tempStatus = 'all'),
                      ),
                      _customFilterChip(
                        label: 'Sudah Dicatat',
                        isSelected: tempStatus == 'checked',
                        onTap: () =>
                            setSheetState(() => tempStatus = 'checked'),
                      ),
                      _customFilterChip(
                        label: 'Belum Dicatat',
                        isSelected: tempStatus == 'unchecked',
                        onTap: () =>
                            setSheetState(() => tempStatus = 'unchecked'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedFloors = tempFloors;
                          _statusFilter = tempStatus;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange.withOpacity(
                          0.3,
                        ),
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
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

  // -----------------------------------------------------------------------
  // CUSTOM WIDGETS FOR NEW STYLE
  // -----------------------------------------------------------------------

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: Colors.white70,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _customFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          // Transparent Orange if selected, Black Trans if not
          color: isSelected
              ? AppColors.primaryOrange.withOpacity(0.25)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryOrange.withOpacity(0.5)
                : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.primaryOrange.withOpacity(0.8)
                : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterBar() {
    final hasFloor = _selectedFloors.isNotEmpty;
    final hasStatus = _statusFilter != 'all';

    if (!hasFloor && !hasStatus) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ..._selectedFloors.map(
            (f) => _activeAppleChip(
              f,
              () => setState(() => _selectedFloors.remove(f)),
            ),
          ),
          if (hasStatus)
            _activeAppleChip(
              _statusFilter == 'checked' ? 'Sudah Dicatat' : 'Belum Dicatat',
              () => setState(() => _statusFilter = 'all'),
            ),
        ],
      ),
    );
  }

  Widget _activeAppleChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryOrange.withOpacity(0.3),
          width: 1,
        ),
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
  }

  // -----------------------------------------------------------------------
  // MAIN BUILD
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainLayout(
        child: SafeArea(
          child: FutureBuilder<List<Tenant>>(
            future: _tenantData,
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

              final allTenants = snapshot.data ?? [];
              final filteredData = _getFilteredData(allTenants);

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    AppHeader(
                      title: "Daftar Unit",
                      titleIcon: Icons.house_outlined,
                      onBack: widget.onBack,
                    ),
                    const SizedBox(height: 16),
                    const PageHeader(
                      title: "Daftar Unit",
                      subtitle: "Braga8 Utility Billing Management",
                    ),
                    const SizedBox(height: 30),

                    // Search Bar & Filter Button Row
                    Row(
                      children: [
                        Expanded(
                          child: CustomSearchBar(
                            controller: _searchController,
                            hintText: "Cari Tenant / Unit...",
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            onSearchPressed: () => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _showFilterModal(allTenants),
                          child: Container(
                            height:
                                50, // Matches standard CustomSearchBar height
                            width: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withValues(
                                alpha: 0.3,
                              ),
                              // Border dibuat lebih tipis (0.8) dan lebih transparan (0.2)
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              // Tambahkan sedikit shadow halus jika ingin efek kedalaman
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

                    if (filteredData.isEmpty)
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
                      ...filteredData.map((entry) {
                        final tenant = entry.key;
                        final units = entry.value;

                        return TableCard(
                          prefix: "Tenant:",
                          suffixText: "${units.length} Unit",
                          main: tenant.name,
                          columnWidths: const {
                            0: FlexColumnWidth(1.2),
                            1: FlexColumnWidth(1.5),
                            2: FlexColumnWidth(1.5),
                            3: FlexColumnWidth(1.5),
                            4: FlexColumnWidth(1.8),
                          },
                          columns: const [
                            "Unit",
                            "Lantai",
                            "Meter Listrik",
                            "Meter Air",
                            "Tindakan",
                          ],
                          data: units.map((u) => {'object': u}).toList(),
                          rowBuilder: (item) {
                            final unit = item['object'] as Unit;
                            final isChecked = _isUnitChecked(unit);
                            return [
                              Text(
                                unit.unitNumber,
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                unit.floor,
                                style: const TextStyle(color: Colors.white),
                              ),
                              StatusBadge(isChecked: unit.isElecChecked),
                              StatusBadge(isChecked: unit.isWaterChecked),
                              SizedBox(
                                height: 36,
                                width: 130,
                                child: ActionButtonTable(
                                  label: isChecked
                                      ? "Lihat Data"
                                      : "Masukkan Data",
                                  icon: isChecked
                                      ? Icons.visibility
                                      : Icons.add,
                                  color: isChecked
                                      ? Colors.blueGrey
                                      : AppColors.primaryOrange.withOpacity(
                                          0.9,
                                        ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailUnitScreen(
                                          shopName: tenant.name,
                                          unit: unit,
                                          onBack: () => Navigator.pop(context),
                                        ),
                                      ),
                                    ).then((_) => _loadData());
                                  },
                                ),
                              ),
                            ];
                          },
                        );
                      }),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
