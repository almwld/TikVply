import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التنبيهات')),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          final notifications = provider.notifications;
          if (notifications.isEmpty) return const Center(child: Text('لا توجد تنبيهات'));
          return RefreshIndicator(
            onRefresh: provider.loadNotifications,
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return ListTile(
                  leading: CircleAvatar(child: Icon(_icon(item.type))),
                  title: Text(item.user?.username ?? 'مستخدم'),
                  subtitle: Text(item.message),
                  trailing: item.isRead ? null : const CircleAvatar(radius: 4),
                  onTap: () => provider.markAsRead(item.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  IconData _icon(NotificationType type) {
    switch (type) {
      case NotificationType.like: return Icons.favorite_rounded;
      case NotificationType.comment: return Icons.chat_bubble_rounded;
      case NotificationType.follow: return Icons.person_add_alt_1_rounded;
      case NotificationType.mention: return Icons.alternate_email_rounded;
      case NotificationType.share: return Icons.share_rounded;
      case NotificationType.live: return Icons.videocam_rounded;
      case NotificationType.gift: return Icons.card_giftcard_rounded;
      case NotificationType.system: return Icons.info_outline_rounded;
    }
  }
}
