import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/video/video_page.dart';
import '../settings/settings_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي'), actions: [
        IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())), icon: const Icon(Icons.settings_outlined)),
        IconButton(onPressed: () => Share.share('TikVply'), icon: const Icon(Icons.share_outlined)),
      ]),
      body: Consumer2<AuthProvider, VideoProvider>(builder: (context, auth, videos, _) {
        final user = auth.currentUser;
        return Column(children: [
          const SizedBox(height: 20),
          CircleAvatar(radius: 45, child: user == null ? const Icon(Icons.person, size: 42) : Text(user.username.substring(0, 1).toUpperCase())),
          const SizedBox(height: 8),
          Text(user?.fullName ?? 'مستخدم TikVply', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (user != null) Text('@${user.username}', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Text('المتابعون ${auth.userStats.followersCount}'), Text('أتابع ${auth.userStats.followingCount}'), Text('الإعجابات ${auth.userStats.likesCount}')]),
          Padding(padding: const EdgeInsets.all(16), child: Row(children: [Expanded(child: FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())), icon: const Icon(Icons.edit), label: const Text('تعديل الملف')))])),
          Expanded(child: videos.videos.isEmpty ? const Center(child: Text('لا يوجد محتوى بعد')) : GridView.builder(padding: const EdgeInsets.all(5), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4), itemCount: videos.videos.length, itemBuilder: (_, i) => InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPage(video: videos.videos[i]))), child: const ColoredBox(color: Color(0xFF102624), child: Icon(Icons.play_arrow, color: Colors.white))))),
        ]);
      }),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الملف الشخصي')), body: Center(child: Text('المستخدم: $userId')));
}
