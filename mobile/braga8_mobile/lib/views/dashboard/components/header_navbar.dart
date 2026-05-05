import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/components/notification_modal.dart';
import 'package:braga8_mobile/data/models/user_model.dart';
import 'package:braga8_mobile/views/core/app_colors.dart';
import 'package:braga8_mobile/views/dashboard/components/account_modal_tenant.dart';
import 'package:flutter/material.dart';

class HeaderNavbar extends StatelessWidget {
  final UserModel user;
  final ApiService api;
  final String token; // Added token to pass to the modal

  const HeaderNavbar({
    super.key,
    required this.user,
    required this.token, // Require token for API calls
    required this.api,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () async {
              final notifications = await api.getNotifications(
                user.token ?? "",
              );

              showDialog(
                context: context,
                builder: (context) => NotificationModal(
                  notifications: notifications, // Pass the fetched data
                  token: user.token ?? "",
                  api: api,
                  onRefresh: () {
                    /* Add refresh logic here */
                  },
                ),
              );

              // Trigger the modal - the modal should handle the
              // internal FutureBuilder or call to api.getNotifications()
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => NotificationModal(
                  notifications:
                      const [], // If the modal fetches its own data, leave empty
                  token: token,
                  api: api,
                  onRefresh: () {
                    // Logic to refresh data if necessary
                    print("Refreshing notifications...");
                  },
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.notifications, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 20),
          InkWell(
            onTap: () => showDialog(
              context: context,
              builder: (context) => AccountModalTenant(user: user),
            ),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.primaryOrange,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
