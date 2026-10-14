import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_glass.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final String type; // 'system', 'reward', 'security'
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

class NotificationController extends GetxController {
  final notifications = <NotificationModel>[
    NotificationModel(
      id: '1',
      title: 'Crazy Monday Reward Available!',
      message: 'Participate in the Crazy Monday event now and win up to ৳100,000 cash rewards directly in your wallet.',
      time: '10 mins ago',
      type: 'reward',
      isRead: false,
    ),
    NotificationModel(
      id: '2',
      title: 'Daily Commission Credited',
      message: 'Your VIP Level 1 team generated ৳1238.00 in commission today. Check your balance wallet.',
      time: '2 hours ago',
      type: 'system',
      isRead: false,
    ),
    NotificationModel(
      id: '3',
      title: 'Official Announcement',
      message: 'Projonmo platform scheduled maintenance completed successfully. All recharge and withdraw gateways are operational.',
      time: '1 day ago',
      type: 'system',
      isRead: true,
    ),
    NotificationModel(
      id: '4',
      title: 'Security Alert',
      message: 'Your account was accessed from a new Chrome session. If this wasn\'t you, please change your password immediately.',
      time: '2 days ago',
      type: 'security',
      isRead: true,
    ),
  ].obs;

  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      final n = notifications[i];
      notifications[i] = NotificationModel(
        id: n.id,
        title: n.title,
        message: n.message,
        time: n.time,
        type: n.type,
        isRead: true,
      );
    }
    Get.snackbar(
      'Notifications',
      'All notifications marked as read',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: AppGlass.flexibleSpace,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Notifications',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(Icons.done_all_rounded, color: AppColors.primary),
            onPressed: controller.markAllAsRead,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 54, color: AppColors.textMuted),
                SizedBox(height: 12),
                Text('No notifications found', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          itemCount: controller.notifications.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (ctx, idx) {
            final item = controller.notifications[idx];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: item.isRead ? Colors.white.withValues(alpha: 0.9) : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: item.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.4),
                  width: item.isRead ? 1 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: _getBgColor(item.type),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_getIcon(item.type), size: 20, color: _getIconColor(item.type)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                  fontSize: 13.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.time,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.message,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: item.isRead ? AppColors.textSecondary : Colors.black87,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!item.isRead) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      }),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'reward':
        return Icons.card_giftcard_rounded;
      case 'security':
        return Icons.security_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'reward':
        return const Color(0xFFF59E0B);
      case 'security':
        return const Color(0xFFEF4444);
      default:
        return AppColors.primary;
    }
  }

  Color _getBgColor(String type) {
    switch (type) {
      case 'reward':
        return const Color(0xFFFEF3C7);
      case 'security':
        return const Color(0xFFFEE2E2);
      default:
        return AppColors.primaryLight;
    }
  }
}
