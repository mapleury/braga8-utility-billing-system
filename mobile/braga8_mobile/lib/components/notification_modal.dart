import 'package:flutter/material.dart';
import '../data/models/notification_model.dart';
import '../ApiService.dart'; // Ganti ke service yang lu pakai buat delete/mark as read

class NotificationModal extends StatelessWidget {
  final List<NotificationModel> notifications;
  final String token;
  final ApiService api;
  final VoidCallback onRefresh;

  const NotificationModal({
    super.key,
    required this.notifications,
    required this.token,
    required this.api,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Tinggi modal maksimal 70% layar biar gak nutupin semua
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar (garis kecil di atas modal)
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Notifications",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo, // Blue accent
                  ),
                ),
                Text(
                  "${notifications.length} Total",
                  style: TextStyle(color: Colors.grey.shade50, fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),

          Expanded(
            child: notifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 20, endIndent: 20),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      final bool isUnread = item.readAt == null;

                      return Container(
                        color: isUnread ? Colors.blue.withOpacity(0.05) : Colors.transparent,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: isUnread ? Colors.blue : Colors.grey.shade200,
                            radius: 5,
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                              color: isUnread ? Colors.black87 : Colors.grey.shade600,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              item.message,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () async {
                              bool success = await api.deleteNotification(item.id, token);
                              if (success) onRefresh();
                            },
                          ),
                          onTap: () async {
                            if (isUnread) {
                              await api.markAsRead(item.id, token);
                              onRefresh();
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text("No notifications yet", style: TextStyle(color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}