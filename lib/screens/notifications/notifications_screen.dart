import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('التنبيهات'),
            actions: [
              Consumer<NotificationProvider>(
                builder: (context, provider, _) => provider.unreadCount > 0
                    ? TextButton(
                        onPressed: provider.markAllAsRead,
                        child: const Text('قراءة الكل'),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          body: Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) return const _NotificationShimmer();
              final notifications = provider.notifications;
              if (notifications.isEmpty) return _emptyState(provider);

              return RefreshIndicator(
                onRefresh: provider.loadNotifications,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: AlignmentDirectional.centerEnd,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                      ),
                      onDismissed: (_) => provider.deleteNotification(item.id),
                      child: _NotificationTile(
                        item: item,
                        onTap: () => provider.markAsRead(item.id),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _emptyState(NotificationProvider provider) {
    return RefreshIndicator(
      onRefresh: provider.loadNotifications,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 150),
          Icon(Icons.notifications_none_rounded, size: 72, color: Colors.grey),
          SizedBox(height: 14),
          Center(
            child: Text(
              'لا توجد تنبيهات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(height: 8),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'ستظهر هنا الإعجابات والتعليقات والمتابعات عند ربط مصدر التنبيهات الحقيقي.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel item;
  final VoidCallback onTap;
  const _NotificationTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = item.user?.username;
    final title = name == null || name.trim().isEmpty ? 'تنبيه' : name;
    return Material(
      color: item.isRead
          ? Theme.of(context).cardColor
          : AppColors.primary.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: .10),
                foregroundColor: AppColors.primary,
                child: Icon(_icon(item.type)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      item.message.isEmpty ? item.type.displayName : item.message,
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: .72),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _relativeTime(item.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (!item.isRead)
                const Padding(
                  padding: EdgeInsets.only(top: 7, left: 2),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(width: 8, height: 8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Icons.favorite_rounded;
      case NotificationType.comment:
        return Icons.chat_bubble_rounded;
      case NotificationType.follow:
        return Icons.person_add_alt_1_rounded;
      case NotificationType.mention:
        return Icons.alternate_email_rounded;
      case NotificationType.share:
        return Icons.share_rounded;
      case NotificationType.live:
        return Icons.videocam_rounded;
      case NotificationType.gift:
        return Icons.card_giftcard_rounded;
      case NotificationType.system:
        return Icons.info_outline_rounded;
    }
  }

  String _relativeTime(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'الآن';
    if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes} د';
    if (difference.inHours < 24) return 'منذ ${difference.inHours} س';
    return 'منذ ${difference.inDays} ي';
  }
}

class _NotificationShimmer extends StatelessWidget {
  const _NotificationShimmer();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: Colors.black12,
        highlightColor: Colors.white70,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: 8,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, __) => const SizedBox(height: 78, child: Card()),
        ),
      );
}
