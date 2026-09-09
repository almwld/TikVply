import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user/user_model.dart';
import '../../providers/auth_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  int _tab = 0;
  final _tabs = const ['الأعلى', 'المستخدمون', 'الفيديوهات', 'الأصوات', 'الوسوم'];

  @override void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: TextField(controller: _searchController, textInputAction: TextInputAction.search, decoration: InputDecoration(hintText: 'ابحث عن فيديو أو مستخدم أو وسم', prefixIcon: const Icon(Icons.search), suffixIcon: _query.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() => _query = ''); })), onChanged: (v) => setState(() => _query = v.trim()))),
    body: Column(children: [
      SizedBox(height: 52, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), itemCount: _tabs.length, separatorBuilder: (_, __) => const SizedBox(width: 6), itemBuilder: (_, i) => ChoiceChip(label: Text(_tabs[i]), selected: _tab == i, onSelected: (_) => setState(() => _tab = i)))),
      Expanded(child: _query.isEmpty ? _trending() : _results()),
    ]),
  );

  Widget _trending() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('الترند الآن', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
    const SizedBox(height: 12),
    ...List.generate(8, (i) => Card(child: ListTile(leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: .1), child: const Icon(Icons.trending_up, color: AppColors.primary)), title: Text('#ترند_${i + 1}'), subtitle: Text('${(i + 1) * 10}K فيديو'), trailing: const Icon(Icons.chevron_right), onTap: () { _searchController.text = '#ترند_${i + 1}'; setState(() => _query = _searchController.text); }))),
    const SizedBox(height: 18),
    const Text('صنّاع محتوى مقترحون', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
    const SizedBox(height: 12),
    SizedBox(height: 120, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: 10, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => SizedBox(width: 86, child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(userId: 'user_$i'))), child: Column(children: [CircleAvatar(radius: 31, backgroundColor: AppColors.primary, child: const Icon(Icons.person, color: Colors.white)), const SizedBox(height: 7), Text('Creator$i', overflow: TextOverflow.ellipsis)]))))),
  ]);

  Widget _results() {
    final users = List.generate(12, (i) => UserModel(id: 'user_$i', username: 'creator_$i', email: 'creator$i@example.com', fullName: 'صانع محتوى ${i + 1}', avatarUrl: 'https://picsum.photos/100?random=$i', isVerified: i % 3 == 0, createdAt: DateTime.now()));
    if (_tab >= 2) return _mediaResults();
    return ListView.builder(itemCount: users.length, itemBuilder: (_, i) { final u = users[i]; return ListTile(leading: CircleAvatar(backgroundImage: NetworkImage(u.avatarUrl!), onBackgroundImageError: (_, __) {}), title: Row(children: [Text('@${u.username}', style: const TextStyle(fontWeight: FontWeight.w700)), if (u.isVerified) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.verified, size: 16, color: AppColors.primary))]), subtitle: Text(u.fullName ?? ''), trailing: _FollowButton(userId: u.id), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(userId: u.id)))); });
  }

  Widget _mediaResults() => ListView.builder(padding: const EdgeInsets.all(16), itemCount: 12, itemBuilder: (_, i) => Card(child: ListTile(leading: Container(width: 58, height: 72, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.play_circle_fill, color: AppColors.primary, size: 30)), title: Text(_tab == 3 ? 'صوت رائج ${i + 1}' : '#${_query.replaceAll('#', '')}'), subtitle: Text('${(i + 2) * 3}K استخدام'), trailing: const Icon(Icons.chevron_right), onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم اختيار ${_tabs[_tab]}'))))));
}

class _FollowButton extends StatefulWidget {
  final String userId;
  const _FollowButton({required this.userId});
  @override State<_FollowButton> createState() => _FollowButtonState();
}
class _FollowButtonState extends State<_FollowButton> {
  bool following = false;
  @override Widget build(BuildContext context) => OutlinedButton(onPressed: () async { setState(() => following = !following); final auth = context.read<AuthProvider>(); if (following) { await auth.followUser(widget.userId); } else { await auth.unfollowUser(widget.userId); } }, child: Text(following ? 'متابَع' : 'متابعة'));
}

class UserProfileScreen extends StatelessWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الملف الشخصي')), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const CircleAvatar(radius: 48, backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white, size: 44)), const SizedBox(height: 16), Text('@$userId', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 8), const Text('ملف صانع المحتوى'), const SizedBox(height: 20), FilledButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم فتح المحادثة'))), icon: const Icon(Icons.chat_bubble_outline), label: const Text('مراسلة'))])));
}
