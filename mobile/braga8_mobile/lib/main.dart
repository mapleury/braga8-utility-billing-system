import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/views/audit_log_screen.dart';
import 'package:braga8_mobile/views/daftar_unit_screen.dart';
import 'package:flutter/material.dart';
import 'components/profile_modal.dart';
import 'package:braga8_mobile/components/notification_modal.dart';
import 'package:braga8_mobile/data/models/notification_model.dart';
import 'package:braga8_mobile/components/progress_meter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService api = ApiService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Braga 8 System',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      initialRoute: '/', // Your home screen
      routes: {
        '/': (context) =>
            LoginScreen(api: ApiService()), // The screen containing your menu
        '/daftar-unit': (context) =>
            DaftarUnitScreen(api: api), // The screen we built earlier
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  final ApiService api;
  LoginScreen({required this.api});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoggingIn = false;

  void _handleLogin() async {
    setState(() => isLoggingIn = true);
    final response = await widget.api.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    setState(() => isLoggingIn = false);

    if (response != null && response['token'] != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
            api: widget.api,
            token: response['token'],
            role: response['user']['role'],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login Gagal.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.apartment, size: 80, color: Colors.indigo),
            const Text(
              "Braga 8 Login",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoggingIn ? null : _handleLogin,
                child: isLoggingIn
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final ApiService api;
  final String token;
  final String role;

  const DashboardScreen({
    super.key,
    required this.api,
    required this.token,
    required this.role,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 1. Deklarasi variabel di level class
  int totalMeters = 0;
  int readMeters = 0;
  int unreadNotificationsCount = 0; // Tambahkan ini
  bool isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    // Panggil fungsi saat aplikasi dibuka
    _loadDashboardData();
  }

  // Fungsi bungkus agar rapi
  Future<void> _loadDashboardData() async {
    await _fetchUnreadCount();
    if (widget.role.toLowerCase() == 'petugas') {
      await _fetchProgressData();
    }
  }

  // 2. Fungsi fetch notifikasi (Perbaikan Error)
  Future<void> _fetchUnreadCount() async {
    try {
      // Pastikan NotificationModel sudah diimport
      final List<NotificationModel> list = await widget.api.getNotifications(
        widget.token,
      );

      if (mounted) {
        // Cek apakah widget masih ada di layar
        setState(() {
          // Sesuaikan 'readAt' dengan nama properti di NotificationModel kamu
          unreadNotificationsCount = list.where((n) => n.readAt == null).length;
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil jumlah notif: $e");
    }
  }

  Future<void> _fetchProgressData() async {
    if (!mounted) return;
    setState(() => isLoadingStats = true);
    try {
      final stats = await widget.api.getMonthlyStats(widget.token);
      if (mounted) {
        setState(() {
          totalMeters = stats['total'] ?? 0;
          readMeters = stats['readings'] ?? 0;
          isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingStats = false);
      debugPrint("Stats Fetch Error: $e");
    }
  }

  void _openNotificationCenter(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
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
        builder: (context) => NotificationModal(
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

  @override
  Widget build(BuildContext context) {
    bool isPetugas = widget.role.toLowerCase() == 'petugas';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(isPetugas ? 'Petugas Dashboard' : 'Tenant Dashboard'),
        backgroundColor: isPetugas
            ? Colors.orange.shade100
            : Colors.blue.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(api: widget.api),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: isPetugas ? _fetchProgressData : () async {},
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              "Selamat Datang, ${widget.api.currentUser?['name'] ?? widget.role}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isPetugas
                  ? "Monitor entry progress bulan ini."
                  : "Pantau penggunaan utilitas Anda.",
              style: TextStyle(color: Colors.grey.shade600),
            ),

            // REAL PROGRESS METER DATA
            if (isPetugas) ...[
              const SizedBox(height: 20),
              isLoadingStats
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ProgressMeter(total: totalMeters, read: readMeters),
            ],

            const SizedBox(height: 20),

            // Grid section
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: isPetugas
                  ? _buildPetugasButtons(context)
                  : _buildTenantButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPetugasButtons(BuildContext context) {
    return [
      _gridItem(context, 'Meter Input', Icons.speed),
      _gridItem(
        context,
        'Daftar Unit',
        Icons.apartment,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DaftarUnitScreen(api: widget.api),
            ),
          );
        },
      ),
      _gridItem(
        context,
        'History',
        Icons.history,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AuditLogScreen()),
          );
        },
      ),
      _gridItem(
        context,
        'Profile',
        Icons.person,
        onTap: () =>
            showProfileModal(context, widget.api, widget.role, widget.token),
      ),
      _gridItem(
        context,
        'Notifications',
        isNotification: true,
        Icons.notifications,
        onTap: () => _openNotificationCenter(context),
      ),
    ];
  }

  List<Widget> _buildTenantButtons(BuildContext context) {
    return [
      _gridItem(context, 'Meter Analytics', Icons.bar_chart),
      _gridItem(context, 'Invoices', Icons.receipt_long),
      _gridItem(context, 'History', Icons.history),
      _gridItem(context, 'Customer Care', Icons.support_agent),
      _gridItem(
        context,
        'Profile',
        Icons.person,
        onTap: () =>
            showProfileModal(context, widget.api, widget.role, widget.token),
      ),
      _gridItem(
        context,
        'Notifications',
        Icons.notifications,
        isNotification: true,
        onTap: () => _openNotificationCenter(context),
      ),
    ];
  }

  Widget _gridItem(
    BuildContext context,
    String label,
    IconData icon, {
    VoidCallback? onTap,
    bool isNotification = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap:
            onTap ??
            () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('$label segera hadir!'))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              // BUNGKUS ICON DENGAN BADGE
              child: Badge(
                isLabelVisible: isNotification && unreadNotificationsCount > 0,
                label: Text(unreadNotificationsCount.toString()),
                child: Icon(icon, size: 32, color: Colors.indigo),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class TenantListScreen extends StatefulWidget {
  final ApiService api;
  final String token;
  const TenantListScreen({super.key, required this.api, required this.token});
  @override
  State<TenantListScreen> createState() => _TenantListScreenState();
}

class _TenantListScreenState extends State<TenantListScreen> {
  List data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() async {
    final res = await widget.api.getTenants(widget.token);
    setState(() {
      data = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Unit')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(data[i]['nama_tenant'] ?? 'Tanpa Nama'),
                subtitle: Text('Unit: ${data[i]['nomor_unit']}'),
              ),
            ),
    );
  }
}
