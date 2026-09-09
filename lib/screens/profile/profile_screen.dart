import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../models/user/user_model.dart';
import 'edit_profile_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  @override void initState() { super.initState(); _tabs = TabController(length: 3, vsync: this); }
  @override void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(body: Consumer<AuthProvider>(builder: (context, auth, _) {
    final user = auth.currentUser; final stats = auth.userStats;
    return CustomScrollView(slivers: [
      SliverAppBar(pinned: true, expandedHeight: 290, title: Text(user == null ? 'الملف الشخصي' : '@${user.username}'), actions: [IconButton(icon: const Icon(Icons.share_outlined), onPressed: () => Share.share('@${user?.username ?? 'TikVply'} على TikVply')), IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())))], flexibleSpace: FlexibleSpaceBar(background: _header(user, stats))),
      SliverPersistentHeader(pinned: true, delegate: _TabDelegate(TabBar(controller: _tabs, tabs: const [Tab(icon: Icon(Icons.grid_on)), Tab(icon: Icon(Icons.bookmark_outline)), Tab(icon: Icon(Icons.favorite_border))]))),
      SliverFillRemaining(child: TabBarView(controller: _tabs, children: [_videos(), _emptyTab(Icons.bookmark_border, 'الفيديوهات المحفوظة'), _emptyTab(Icons.favorite_border, 'الفيديوهات التي أعجبتك')])),
    ]);
  }));

  Widget _header(UserModel? user, dynamic stats) => Container(padding: const EdgeInsets.only(top: 75), child: Column(children: [
    CircleAvatar(radius: 48, backgroundColor: AppColors.primary, backgroundImage: user?.avatarUrl == null ? null : NetworkImage(user!.avatarUrl!), child: user?.avatarUrl == null ? const Icon(Icons.person, color: Colors.white, size: 44) : null),
    const SizedBox(height: 10), Text(user?.fullName ?? 'مستخدم TikVply', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
    if (user?.bio != null) Padding(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 5), child: Text(user!.bio!, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis)),
    const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_stat('المتابَعون', 'followersCount', stats), _stat('أتابع', 'followingCount', stats), _stat('الإعجابات', 'likesCount', stats)]),
    const SizedBox(height: 12), Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [Expanded(child: FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())), icon: const Icon(Icons.edit_outlined), label: const Text('تعديل الملف'))), const SizedBox(width: 10), OutlinedButton(onPressed: () => _showAccountMenu(context), child: const Icon(Icons.more_horiz))])),
  ]));

  Widget _stat(String label, String key, dynamic s) { final v = key == 'followersCount' ? s.followersCount : key == 'followingCount' ? s.followingCount : s.likesCount; return InkWell(onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label: $v'))), child: Column(children: [Text('$v', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), Text(label, style: const TextStyle(fontSize: 12))])); }

  Widget _videos() => Consumer<VideoProvider>(builder: (context, p, _) => GridView.builder(padding: const EdgeInsets.all(2), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2, childAspectRatio: 9 / 16), itemCount: p.videos.length, itemBuilder: (_, i) { final v = p.videos[i]; return InkWell(onTap: () { p.setCurrentIndex(i); Navigator.popUntil(context, (r) => r.isFirst); }, child: Stack(fit: StackFit.expand, children: [v.thumbnailUrl != null ? Image.network(v.thumbnailUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder()) : _placeholder(), Positioned(left: 5, bottom: 5, child: Row(children: [const Icon(Icons.play_arrow, color: Colors.white, size: 14), Text(v.formatViews(), style: const TextStyle(color: Colors.white, fontSize: 11))]))])); }));
  Widget _placeholder() => Container(color: AppColors.primary.withValues(alpha: .25), child: const Icon(Icons.play_arrow, color: Colors.white, size: 36));
  Widget _emptyTab(IconData icon, String text) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 64, color: Colors.grey), const SizedBox(height: 12), Text(text, style: const TextStyle(color: Colors.grey, fontSize: 16))]));

  void _showAccountMenu(BuildContext context) => showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('الإعدادات'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); }), ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: const Text('الخصوصية'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))), const Divider(), ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)), onTap: () async { Navigator.pop(context); await context.read<AuthProvider>().logout(); if (context.mounted) Navigator.popUntil(context, (r) => r.isFirst); })])));
}

class _TabDelegate extends SliverPersistentHeaderDelegate { final TabBar tabBar; _TabDelegate(this.tabBar); @override double get minExtent => tabBar.preferredSize.height; @override double get maxExtent => tabBar.preferredSize.height; @override Widget build(BuildContext c, double s, bool o) => Container(color: Theme.of(c).scaffoldBackgroundColor, child: tabBar); @override bool shouldRebuild(covariant _TabDelegate old) => false; }
