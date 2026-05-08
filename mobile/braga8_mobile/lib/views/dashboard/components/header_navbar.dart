import 'package:braga8_mobile/ApiService.dart';
import 'package:braga8_mobile/components/profile_modal.dart';
import 'package:braga8_mobile/views/core/app_colors.dart';
import 'package:flutter/material.dart';

class HeaderNavbar extends StatelessWidget {
  final ApiService? api;
  final String token;
  final int unreadCount;
  final VoidCallback? onNotificationTap;

  const HeaderNavbar({
    super.key,
    required this.api,
    required this.token,
    this.unreadCount = 0,
    this.onNotificationTap,
  });

  void _openProfile(BuildContext context) {
    if (api == null) return;
    final role = api!.currentUser?['role'] ?? 'petugas';
    showProfileModal(context, api!, role, token);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onNotificationTap,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: -5,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryOrange,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 1),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openProfile(context),
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryOrange.withOpacity(0.2),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}