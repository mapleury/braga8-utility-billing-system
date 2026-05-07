import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/views/dashboard/components/meter_progress_card.dart';
import 'package:braga8_mobile/views/history/audit_log_screen.dart';
import 'package:braga8_mobile/views/daftar_unit_screen.dart';
import 'package:braga8_mobile/components/notification_modal.dart';
import 'package:braga8_mobile/components/profile_modal.dart';
import 'package:braga8_mobile/data/models/notification_model.dart';
import 'package:braga8_mobile/views/input_reading_screen.dart';
import 'package:braga8_mobile/views/widgets/bottom_navbar_custom.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// DashboardScreen — StatefulWidget, owns nav + data state
// ---------------------------------------------------------------------------
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
  // --- Nav state ---
  late int _selectedIndex;

  // --- Dashboard data state ---
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

  // -----------------------------------------------------------------------
  // DATA FETCHING
  // -----------------------------------------------------------------------

  Future<void> _loadDashboardData() async {
    await _fetchUnreadCount();
    if (widget.role.toLowerCase() == 'petugas') {
      await _fetchProgressData();
    }
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final List<NotificationModel> list = await widget.api.getNotifications(
        widget.token,
      );
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

  // -----------------------------------------------------------------------
  // NOTIFICATION CENTER
  // -----------------------------------------------------------------------

  void _openNotificationCenter(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final List<NotificationModel> list = await widget.api.getNotifications(
        widget.token,
      );
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // -----------------------------------------------------------------------
  // PAGES — built once, kept alive by IndexedStack
  // -----------------------------------------------------------------------

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

  // -----------------------------------------------------------------------
  // BUILD
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool isPetugas = widget.role.toLowerCase() == 'petugas';
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
// Dashboard body — stateless, receives all data via props
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_isPetugas ? 'Petugas Dashboard' : 'Tenant Dashboard'),
        backgroundColor: _isPetugas
            ? Colors.orange.shade100
            : Colors.blue.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "Selamat Datang, ${(() {
                String name = api.currentUser?['name'] ?? role;
                if (name.isEmpty) return name;
                return name[0].toUpperCase() + name.substring(1).toLowerCase();
              })()}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _isPetugas
                  ? "Monitor entry progress bulan ini."
                  : "Pantau penggunaan utilitas Anda.",
              style: TextStyle(color: Colors.white38, fontSize: 15),
            ),
            if (_isPetugas) ...[
              const SizedBox(height: 20),
              isLoadingStats
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.orange,
                          ),
                        ),
                      ),
                    )
                  : MeterProgressCard(
                      total: totalMeters,
                      read: readMeters,
                      period: _currentPeriod(),
                    ),
            ],
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: _isPetugas
                  ? _petugasItems(context)
                  : _tenantItems(context),
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

  String _currentPeriod() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${months[now.month - 1]} ${now.year}';
  }
}

// ---------------------------------------------------------------------------
// Grid menu item card
// ---------------------------------------------------------------------------
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom navigation bar
// ---------------------------------------------------------------------------
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isPetugas;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.isPetugas,
    required this.onTap,
  });

  static const _petugasItems = [
    (Icons.home_filled, 'Home'),
    (Icons.speed, 'Meter'),
    (Icons.domain, 'Units'),
    (Icons.history, 'History'),
    (Icons.person, 'Profile'),
  ];

  static const _tenantItems = [
    (Icons.home_filled, 'Home'),
    (Icons.bar_chart, 'Analytics'),
    (Icons.receipt_long, 'Invoices'),
    (Icons.support_agent, 'Care'),
    (Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final items = isPetugas ? _petugasItems : _tenantItems;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          image: const DecorationImage(
            image: AssetImage('assets/navbar-img.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (i) {
            final (icon, label) = items[i];
            return _NavItem(
              index: i,
              icon: icon,
              label: label,
              isActive: currentIndex == i,
              onTap: onTap,
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isActive;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  static const _orange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20 : 12,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withAlpha(200) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? _orange : Colors.white.withAlpha(180),
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: _orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile page tab
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
