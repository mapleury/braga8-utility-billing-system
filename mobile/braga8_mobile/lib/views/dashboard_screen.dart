import 'package:braga8_mobile/components/progress_meter.dart';
import 'package:braga8_mobile/views/audit_log_screen.dart';
import 'package:flutter/material.dart';
import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/components/notification_modal.dart';
import 'package:braga8_mobile/components/profile_modal.dart';
import 'package:braga8_mobile/data/models/notification_model.dart';

class DashboardScreen extends StatelessWidget {
  final ApiService api;
  final String token;
  final String role;

  const DashboardScreen({
    super.key,
    required this.api,
    required this.token,
    required this.role,
  });

  void _openNotificationCenter(BuildContext context) async {
    // 1. Show Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. Fetch data from Laravel
      final List<NotificationModel> list = await api.getNotifications(token);

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      // 3. Open the Modal with the fetched data
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => NotificationModal(
          notifications: list,
          token: token,
          api: api,
          onRefresh: () {
            Navigator.pop(context); // Close modal
            _openNotificationCenter(context); // Re-fetch to update list
          },
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Notification Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPetugas = role.toLowerCase() == 'petugas';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(isPetugas ? 'Petugas Portal' : 'Tenant Portal'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isPetugas
            ? Colors.orange.shade300
            : Colors.blue.shade300,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          if (isPetugas)
            SliverToBoxAdapter(
              child: ProgressMeter(
                total: 100, // Replace with dynamic data from API
                read: 65, // Replace with dynamic data from API
              ),
            ),
          // Widget Progress Bar yang dimasukkan ke SliverToBoxAdapter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Input Progress",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "April 2026", // Bisa dinamis dari API
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value:
                            0.75, // Ganti dengan (completed / total) dari API
                        minHeight: 12,
                        backgroundColor: Colors.blue.shade50,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "75%", // Dinamis: (value * 100).toInt()
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "45 / 60 Meter Terinput",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Header Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, ${api.currentUser?['name'] ?? role}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isPetugas
                        ? "Manage your assigned units"
                        : "Check your bills and usage",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          // Grid Menu Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate(
                isPetugas
                    ? _buildPetugasMenu(context)
                    : _buildTenantMenu(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPetugasMenu(BuildContext context) {
    return [
      _menuButton(
        context,
        'Meter Input',
        Icons.speed,
        () => print("Meter Input"),
      ),
      // The calling code inside your GridView/Column:
      _menuButton(
        context,
        'Daftar Unit',
        Icons.domain,
        () => Navigator.pushNamed(context, '/daftar-unit'),
      ),
      _menuButton(
        context,
        'History',
        Icons.history,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AuditLogScreen()),
        ),
      ),
      _menuButton(
        context,
        'Profile',
        Icons.person,
        () => showProfileModal(context, api, role, token),
      ),
      _menuButton(
        context,
        'Notifications',
        Icons.notifications_active,
        () => _openNotificationCenter(context),
      ),
    ];
  }

  List<Widget> _buildTenantMenu(BuildContext context) {
    return [
      _menuButton(
        context,
        'Analytics',
        Icons.bar_chart,
        () => print("Analytics"),
      ),
      _menuButton(
        context,
        'Invoices',
        Icons.receipt_long,
        () => print("Invoices"),
      ),
      _menuButton(
        context,
        'Customer Care',
        Icons.support_agent,
        () => print("Customer Care"),
      ),
      _menuButton(
        context,
        'Profile',
        Icons.person,
        () => showProfileModal(context, api, role, token),
      ),
      _menuButton(
        context,
        'Notifications',
        Icons.notifications_active,
        () => _openNotificationCenter(context),
      ),
    ];
  }

  Widget _menuButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap, // Triggers the Navigator.pushNamed
        borderRadius: BorderRadius.circular(15),
        splashColor: Colors.indigo.withOpacity(0.05),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: Colors.indigo.shade700),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
