import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التنبيهات'), actions: [Consumer<NotificationProvider>(builder: (_, p, __) => p.unreadCount == 0 ? const SizedBox.shrink() : TextButton(onPressed: p.markAllAsRead, child: const Text('قراءة الكل')))]),
      body: Consumer<NotificationProvider>(builder: (context, p, _) {
        if (p.isLoading) return const Center(child: CircularProgressIndicator());
        if (p.notifications.isEmpty) return _empty(context);
        return RefreshIndicator(onRefresh: p.loadNotifications, child: ListView.builder(itemCount: p.notifications.length, itemBuilder: (_, i) {
          final notification = p.notifications[i];
          return Dismissible(
            key: ValueKey(notification.id), direction: DismissDirection.endToStart,
            background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
            onDismissed: (_) => p.deleteNotification(notification.id), child: _NotificationTile(notification: notification));
        }));
      }),
    );
  }
  Widget _empty(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey[400]), const SizedBox(height: 14), const Text('لا توجد تنبيهات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)), const SizedBox(height: 8), const Text('ستظهر التفاعلات والمتابعات هنا')]));
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationTile({required this.notification});
  @override
  Widget build(BuildContext context) => Material(
    color: notification.isRead ? Colors.transparent : AppColors.primary.withValues(alpha: .06),
    child: ListTile(
      leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: .12), child: Icon(_icon(notification.type), color: AppColors.primary)),
      title: Text('${notification.user?.username ?? 'مستخدم'} ${notification.type.displayName}', style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text('${notification.message}\n${_time(notification.createdAt)}'), isThreeLine: true,
      trailing: notification.isRead ? null : const CircleAvatar(radius: 4, backgroundColor: AppColors.primary),
      onTap: () async { await context.read<NotificationProvider>().markAsRead(notification.id); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تعليم التنبيه كمقروء'))); },
    ),
  );
  IconData _icon(NotificationType t) => switch (t) {
    NotificationType.like => Icons.favorite, NotificationType.comment => Icons.chat_bubble, NotificationType.follow => Icons.person_add,
    NotificationType.mention => Icons.alternate_email, NotificationType.share => Icons.share, NotificationType.live => Icons.videocam,
    NotificationType.gift => Icons.card_giftcard, NotificationType.system => Icons.info,
  };
  String _time(DateTime d) { final x = DateTime.now().difference(d); if (x.inMinutes < 60) return 'منذ ${x.inMinutes} دقيقة'; if (x.inHours < 24) return 'منذ ${x.inHours} ساعة'; if (x.inDays < 7) return 'منذ ${x.inDays} يوم'; return '${d.day}/${d.month}/${d.year}'; }
}
