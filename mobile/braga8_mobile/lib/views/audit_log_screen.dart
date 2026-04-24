import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/data/models/audit_log_model.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final ApiService _apiService = ApiService();
  int _currentPage = 1;
  int _lastPage = 1;
  List<AuditLog> _logs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.fetchLogs(_currentPage);
      setState(() {
        _logs = res.data;
        _lastPage = res.lastPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _getActionColor(String action) {
    if (action.contains('created')) return Colors.green;
    if (action.contains('updated')) return Colors.orange;
    if (action.contains('deleted')) return Colors.red;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History Aktivitas")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _logs.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getActionColor(
                            log.action,
                          ).withOpacity(0.1),
                          child: Icon(
                            Icons.history,
                            color: _getActionColor(log.action),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          log.description, // Menampilkan "User updated a record..."
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          "${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(log.createdAt))} • oleh ${log.userName}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
                _buildPaginationControls(),
              ],
            ),
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            onPressed: _currentPage > 1
                ? () {
                    _currentPage--;
                    _fetchData();
                  }
                : null,
          ),
          Text("Halaman $_currentPage dari $_lastPage"),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: _currentPage < _lastPage
                ? () {
                    _currentPage++;
                    _fetchData();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
