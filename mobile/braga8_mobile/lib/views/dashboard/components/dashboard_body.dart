import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/components/notification_modal.dart';
import 'package:braga8_mobile/components/profile_modal.dart';
import 'package:braga8_mobile/data/models/notification_model.dart';
import 'package:braga8_mobile/data/models/user_model.dart';
import 'package:braga8_mobile/views/daftar_unit/daftar_unit_screen.dart';
import 'package:braga8_mobile/views/dashboard/components/header_navbar.dart';
import 'package:braga8_mobile/views/history/audit_log_screen.dart';
import 'package:braga8_mobile/views/meter_input/input_reading_screen.dart';
import 'package:braga8_mobile/views/widgets/bottom_navbar_custom.dart';
import 'package:braga8_mobile/views/widgets/page_header.dart';
import 'package:flutter/material.dart';
import 'menu_grid.dart';
import 'meter_progress_card.dart';

class DashboardScreen extends StatefulWidget {
  final ApiService api;
  final String token;
  final String role;
  final int initialIndex;

  const DashboardScreen({
    super.key,
    required this.api,
    required this.token,
    required this.role,
    this.initialIndex = 0,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _selectedIndex;

  int _totalMeters = 0;
  int _readMeters = 0;
  int _unreadCount = 0;
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadDashboardData();
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Future<void> _loadDashboardData() async {
    await _fetchUnreadCount();
    if (widget.role.toLowerCase() == 'petugas') await _fetchProgressData();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final List<NotificationModel> list =
          await widget.api.getNotifications(widget.token);
      if (mounted) {
        setState(() {
          _unreadCount = list.where((n) => n.readAt == null).length;
        });
      }
    } catch (e) {
      debugPrint("Gagal fetch notif count: $e");
    }
  }

  Future<void> _fetchProgressData() async {
    if (!mounted) return;
    setState(() => _isLoadingStats = true);
    try {
      final stats = await widget.api.getMonthlyStats(widget.token);
      if (mounted) {
        setState(() {
          _totalMeters = stats['total'] ?? 0;
          _readMeters = stats['readings'] ?? 0;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStats = false);
      debugPrint("Stats fetch error: $e");
    }
  }

  void _openNotificationCenter(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final List<NotificationModel> list =
          await widget.api.getNotifications(widget.token);
      if (!context.mounted) return;
      Navigator.pop(context);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => NotificationModal(
          notifications: list,
          token: widget.token,
          api: widget.api,
          onRefresh: () {
            Navigator.pop(context);
            _openNotificationCenter(context);
          },
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  List<Widget> get _pages {
    final bool isPetugas = widget.role.toLowerCase() == 'petugas';
    if (isPetugas) {
      return [
        _DashboardBody(
          api: widget.api,
          token: widget.token,
          role: widget.role,
          totalMeters: _totalMeters,
          readMeters: _readMeters,
          unreadCount: _unreadCount,
          isLoadingStats: _isLoadingStats,
          onNavTap: _onItemTapped,
          onRefresh: _fetchProgressData,
          onOpenNotifications: _openNotificationCenter,
        ),
        InputReadingScreen(onBack: () => _onItemTapped(0)),
        DaftarUnitScreen(api: widget.api, onBack: () => _onItemTapped(0)),
        AuditLogScreen(onBack: () => _onItemTapped(0)),
        _ProfilePage(api: widget.api, role: widget.role, token: widget.token),
      ];
    }
    return [
      _DashboardBody(
        api: widget.api,
        token: widget.token,
        role: widget.role,
        totalMeters: _totalMeters,
        readMeters: _readMeters,
        unreadCount: _unreadCount,
        isLoadingStats: _isLoadingStats,
        onNavTap: _onItemTapped,
        onRefresh: () async {},
        onOpenNotifications: _openNotificationCenter,
      ),
      const Scaffold(body: Center(child: Text("Analytics"))),
      const Scaffold(body: Center(child: Text("Invoices"))),
      const Scaffold(body: Center(child: Text("Customer Care"))),
      _ProfilePage(api: widget.api, role: widget.role, token: widget.token),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey.shade50,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavbarCustom(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dashboard body — ProgressMeter replaced with MeterProgressCard
// ---------------------------------------------------------------------------
class _DashboardBody extends StatelessWidget {
  final ApiService api;
  final String token;
  final String role;
  final int totalMeters;
  final int readMeters;
  final int unreadCount;
  final bool isLoadingStats;
  final ValueChanged<int> onNavTap;
  final Future<void> Function() onRefresh;
  final void Function(BuildContext) onOpenNotifications;

  const _DashboardBody({
    required this.api,
    required this.token,
    required this.role,
    required this.totalMeters,
    required this.readMeters,
    required this.unreadCount,
    required this.isLoadingStats,
    required this.onNavTap,
    required this.onRefresh,
    required this.onOpenNotifications,
  });

  bool get _isPetugas => role.toLowerCase() == 'petugas';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_isPetugas ? 'Petugas Dashboard' : 'Tenant Dashboard'),
        backgroundColor:
            _isPetugas ? Colors.orange.shade100 : Colors.blue.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "Selamat Datang, ${api.currentUser?['name'] ?? role}",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _isPetugas
                  ? "Monitor entry progress bulan ini."
                  : "Pantau penggunaan utilitas Anda.",
              style: TextStyle(color: Colors.grey.shade600),
            ),

            // ── NEW: MeterProgressCard replaces ProgressMeter ──────────
            if (_isPetugas) ...[
              const SizedBox(height: 20),
              isLoadingStats
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : MeterProgressCard(
                      total: totalMeters,
                      read: readMeters, period: 'Bulan Ini',
                    ),
            ],
            // ───────────────────────────────────────────────────────────

            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children:
                  _isPetugas ? _petugasItems(context) : _tenantItems(context),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  List<Widget> _petugasItems(BuildContext context) => [
        _GridItem('Meter Input', Icons.speed, () => onNavTap(1)),
        _GridItem('Daftar Unit', Icons.apartment, () => onNavTap(2)),
        _GridItem('History', Icons.history, () => onNavTap(3)),
        _GridItem(
          'Profile',
          Icons.person,
          () => showProfileModal(context, api, role, token),
        ),
        _GridItem(
          'Notifications',
          Icons.notifications,
          () => onOpenNotifications(context),
          badgeCount: unreadCount,
        ),
      ];

  List<Widget> _tenantItems(BuildContext context) => [
        _GridItem('Meter Analytics', Icons.bar_chart, () => onNavTap(1)),
        _GridItem('Invoices', Icons.receipt_long, () => onNavTap(2)),
        _GridItem('Customer Care', Icons.support_agent, () => onNavTap(3)),
        _GridItem(
          'Profile',
          Icons.person,
          () => showProfileModal(context, api, role, token),
        ),
        _GridItem(
          'Notifications',
          Icons.notifications,
          () => onOpenNotifications(context),
          badgeCount: unreadCount,
        ),
      ];
}

class _GridItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  const _GridItem(this.label, this.icon, this.onTap, {this.badgeCount = 0});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Badge(
                isLabelVisible: badgeCount > 0,
                label: Text(badgeCount.toString()),
                child: Icon(icon, size: 32, color: Colors.indigo),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile page tab — unchanged
// ---------------------------------------------------------------------------
class _ProfilePage extends StatefulWidget {
  final ApiService api;
  final String role;
  final String token;

  const _ProfilePage({
    required this.api,
    required this.role,
    required this.token,
  });

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  bool _modalShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_modalShown) {
      _modalShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted)
          showProfileModal(context, widget.api, widget.role, widget.token);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}