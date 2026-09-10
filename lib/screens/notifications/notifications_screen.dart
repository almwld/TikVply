import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _filter = 0;
  final _filters = const ['الكل', 'الإعجابات', 'التعليقات', 'المتابعات'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التنبيهات'), actions: [Consumer<NotificationProvider>(builder: (_, p, __) => p.unreadCount > 0 ? TextButton(onPressed: p.markAllAsRead, child: const Text('قراءة الكل')) : const SizedBox.shrink())]),
      body: Consumer<NotificationProvider>(builder: (context, provider, _) {
        final list = _filtered(provider.notifications);
        return RefreshIndicator(onRefresh: provider.loadNotifications, child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 54, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), itemCount: _filters.length, separatorBuilder: (_, __) => const SizedBox(width: 7), itemBuilder: (_, i) => ChoiceChip(label: Text(_filters[i]), selected: _filter == i, onSelected: (_) => setState(() => _filter = i)))),
          if (provider.isLoading) const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
          if (!provider.isLoading && list.isEmpty) SliverFillRemaining(hasScrollBody: false, child: _empty()),
          if (!provider.isLoading && list.isNotEmpty) SliverList(delegate: SliverChildBuilderDelegate((_, i) => _NotificationTile(notification: list[i]), childCount: list.length)),
        ]));
      }),
    );
  }

  List<NotificationModel> _filtered(List<NotificationModel> source) {
    if (_filter == 0) return source;
    final types = [_filter == 1 ? NotificationType.like : _filter == 2 ? NotificationType.comment : NotificationType.follow];
    return source.where((n) => n.type == types.first).toList();
  }

  Widget _empty() => Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.notifications_none_rounded, size: 82, color: Colors.grey.shade400), const SizedBox(height: 14), const Text('لا توجد تنبيهات', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), const SizedBox(height: 8), const Text('ستظهر الإعجابات والتعليقات والمتابعات الجديدة هنا.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))])));
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationTile({required this.notification});
  @override
  Widget build(BuildContext context) => Dismissible(
    key: ValueKey(notification.id), direction: DismissDirection.endToStart,
    background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete_outline, color: Colors.white)),
    onDismissed: (_) => context.read<NotificationProvider>().deleteNotification(notification.id),
    child: Material(color: notification.isRead ? Colors.transparent : AppColors.primary.withValues(alpha: .06), child: InkWell(onTap: () => context.read<NotificationProvider>().markAsRead(notification.id), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(radius: 25, backgroundColor: AppColors.primary.withValues(alpha: .12), child: Icon(_icon(notification.type), color: AppColors.primary)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${notification.user?.username ?? 'مستخدم'} ${notification.type.displayName}', style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(notification.message, maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 5), Text(_time(notification.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 11))])),
      if (!notification.isRead) const Padding(padding: EdgeInsets.only(top: 7), child: CircleAvatar(radius: 4, backgroundColor: AppColors.primary)),
    ]))));

  IconData _icon(NotificationType t) => switch (t) { NotificationType.like => Icons.favorite_rounded, NotificationType.comment => Icons.chat_bubble_rounded, NotificationType.follow => Icons.person_add_alt_1_rounded, NotificationType.mention => Icons.alternate_email_rounded, NotificationType.share => Icons.share_rounded, NotificationType.live => Icons.videocam_rounded, NotificationType.gift => Icons.card_giftcard_rounded, NotificationType.system => Icons.info_outline_rounded };
  String _time(DateTime d) { final x = DateTime.now().difference(d); if (x.inMinutes < 1) return 'الآن'; if (x.inMinutes < 60) return 'منذ ${x.inMinutes} دقيقة'; if (x.inHours < 24) return 'منذ ${x.inHours} ساعة'; if (x.inDays < 7) return 'منذ ${x.inDays} يوم'; return '${d.day}/${d.month}/${d.year}'; }
}
