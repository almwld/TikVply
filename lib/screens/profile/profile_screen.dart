import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../models/user/user_model.dart';
import '../../services/video_thumbnail_service.dart';
import '../settings/settings_screen.dart';
import 'edit_profile_screen.dart';

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
    return NestedScrollView(headerSliverBuilder: (_, __) => [
      SliverAppBar(pinned: true, expandedHeight: 300, title: Text(user == null ? 'الملف الشخصي' : '@${user.username}'), actions: [IconButton(tooltip: 'مشاركة', icon: const Icon(Icons.share_outlined), onPressed: () => Share.share('@${user?.username ?? 'TikVply'} على TikVply')), IconButton(tooltip: 'الإعدادات', icon: const Icon(Icons.settings_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())))], flexibleSpace: FlexibleSpaceBar(background: _header(user, stats))),
      SliverPersistentHeader(pinned: true, delegate: _TabDelegate(TabBar(controller: _tabs, tabs: const [Tab(icon: Icon(Icons.grid_on_rounded)), Tab(icon: Icon(Icons.bookmark_outline_rounded)), Tab(icon: Icon(Icons.favorite_border_rounded))]))),
    ], body: TabBarView(controller: _tabs, children: [_videoGrid((v) => true), _videoGrid((v) => v.isSaved), _videoGrid((v) => v.isLiked)]));
  }));

  Widget _header(UserModel? user, dynamic stats) => Container(padding: const EdgeInsets.only(top: 76, left: 18, right: 18), child: Column(children: [
    CircleAvatar(radius: 45, backgroundColor: AppColors.primary, backgroundImage: user?.avatarUrl == null ? null : NetworkImage(user!.avatarUrl!), child: user?.avatarUrl == null ? const Icon(Icons.person_rounded, color: Colors.white, size: 42) : null),
    const SizedBox(height: 9), Text(user?.fullName ?? 'مستخدم TikVply', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
    if (user?.username != null) Text('@${user!.username}', style: const TextStyle(color: Colors.grey)),
    if (user?.bio != null && user!.bio!.trim().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 5), child: Text(user.bio!, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis)),
    const SizedBox(height: 10), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_Stat(value: '${stats.followersCount}', label: 'المتابعون'), _Stat(value: '${stats.followingCount}', label: 'أتابع'), _Stat(value: '${stats.likesCount}', label: 'الإعجابات')]),
    const SizedBox(height: 11), Row(children: [Expanded(child: FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())), icon: const Icon(Icons.edit_outlined), label: const Text('تعديل الملف'))), const SizedBox(width: 8), OutlinedButton(onPressed: () => _showMenu(context), child: const Icon(Icons.more_horiz_rounded))]),
  ]));

  Widget _videoGrid(bool Function(dynamic) filter) => Consumer<VideoProvider>(builder: (context, provider, _) {
    final list = provider.videos.where(filter).toList();
    if (list.isEmpty) return _empty();
    return GridView.builder(padding: const EdgeInsets.all(3), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 3, childAspectRatio: .68), itemCount: list.length, itemBuilder: (_, i) { final video = list[i]; return InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ProfileVideoViewer(video: video))), child: Stack(fit: StackFit.expand, children: [_Thumb(path: video.videoUrl), const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black54]))), Positioned(right: 5, bottom: 5, child: Row(children: [const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14), const SizedBox(width: 2), Text(video.formatViews(), style: const TextStyle(color: Colors.white, fontSize: 10))]))])); });
  });

  Widget _empty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.video_library_outlined, size: 68, color: Colors.grey.shade400), const SizedBox(height: 12), const Text('لا يوجد محتوى بعد', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700))]));
  Future<void> _showMenu(BuildContext context) async { showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('الإعدادات'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); }), ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: const Text('الخصوصية'), onTap: () { Navigator.pop(context); _info('الخصوصية', 'يمكنك التحكم في المظهر وإعدادات تشغيل الفيديو من الإعدادات.'); }), const Divider(), ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)), onTap: () async { Navigator.pop(context); await context.read<AuthProvider>().logout(); })]))); }
  void _info(String title, String body) => showDialog<void>(context: context, builder: (_) => AlertDialog(title: Text(title), content: Text(body), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسنًا'))]));
}

class _Stat extends StatelessWidget { final String value; final String label; const _Stat({required this.value, required this.label}); @override Widget build(BuildContext context) => Column(children: [Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey))]); }

class _Thumb extends StatelessWidget { final String path; const _Thumb({required this.path}); @override Widget build(BuildContext context) { if (path.startsWith('http')) return Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback()); return FutureBuilder<String?>(future: VideoThumbnailService.instance.getThumbnailPath(path), builder: (_, s) => s.hasData && s.data!.isNotEmpty ? Image.file(File(s.data!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback()) : _fallback()); } Widget _fallback() => const ColoredBox(color: Color(0xFF102624), child: Center(child: Icon(Icons.video_file_rounded, color: Colors.white54, size: 28))); }

class _ProfileVideoViewer extends StatelessWidget { final dynamic video; const _ProfileVideoViewer({required this.video}); @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black, body: SafeArea(child: VideoPlayerPageForProfile(video: video))); }
class VideoPlayerPageForProfile extends StatelessWidget { final dynamic video; const VideoPlayerPageForProfile({required this.video}); @override Widget build(BuildContext context) { return const SizedBox.shrink(); } }

class _TabDelegate extends SliverPersistentHeaderDelegate { final TabBar tabBar; _TabDelegate(this.tabBar); @override double get minExtent => tabBar.preferredSize.height; @override double get maxExtent => tabBar.preferredSize.height; @override Widget build(BuildContext c, double s, bool o) => Container(color: Theme.of(c).scaffoldBackgroundColor, child: tabBar); @override bool shouldRebuild(covariant _TabDelegate old) => false; }
