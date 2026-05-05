import 'dart:ui';
import 'package:braga8_mobile/views/core/app_colors.dart';
import 'package:flutter/material.dart';
import '../data/models/notification_model.dart';
import '../ApiService.dart'; 

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
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ), 
        child: Container(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height *
                0.75, 
          ),
          decoration: BoxDecoration(
           
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15), 
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Notifikasi",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryOrange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "${notifications.length} Total",
                        style: TextStyle(
                          color: AppColors.primaryOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white24, height: 20),

              Expanded(
                child: notifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24, top: 8),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final item = notifications[index];
                          final bool isUnread = item.readAt == null;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: _buildNotificationItem(item, isUnread),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel item, bool isUnread) {
    return Dismissible(
      key: Key(item.id.toString()),
      direction: isUnread ? DismissDirection.endToStart : DismissDirection.none,

      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange.withValues(
            alpha: 0.6,
          ), 
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Tandai Dibaca",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.mark_email_read, color: Colors.white),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
      
        await api.markAsRead(item.id, token);
        onRefresh();
        return false; 
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.primaryOrange.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? AppColors.primaryOrange.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnread ? AppColors.primaryOrange : Colors.transparent,
              border: isUnread
                  ? null
                  : Border.all(color: Colors.white24, width: 1.5),
              boxShadow: isUnread
                  ? [
                      BoxShadow(
                        color: AppColors.primaryOrange.withValues(alpha: 0.9),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
          ),
          title: Text(
            item.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
              color: isUnread ? Colors.white : Colors.white60,
            ),
          ),
          subtitle: Text(
            item.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isUnread ? Colors.white70 : Colors.white38,
              fontSize: 13,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.redAccent.withValues(alpha: 0.6),
              size: 20,
            ),
            onPressed: () async {
              bool success = await api.deleteNotification(item.id, token);
              if (success) onRefresh();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 50,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Belum ada notifikasi",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
