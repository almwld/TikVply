import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/video/video_model.dart';
import '../../providers/feed_provider.dart';
import '../../services/video_thumbnail_service.dart';
import '../../widgets/video/video_page.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  String _query = '';
  int _category = 0;
  final _categories = const ['الكل', 'الأحدث', 'الأكثر مشاهدة', 'المحفوظة'];

  @override
  void dispose() { _controller.dispose(); _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اكتشف'), centerTitle: false, actions: [IconButton(tooltip: 'البحث', onPressed: _focus.requestFocus, icon: const Icon(Icons.search_rounded))]),
      body: Consumer<VideoProvider>(builder: (context, provider, _) {
        final videos = _filtered(provider.videos);
        return RefreshIndicator(
          onRefresh: provider.refreshDeviceVideos,
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 6), child: _searchBox())),
            SliverToBoxAdapter(child: SizedBox(height: 48, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), itemCount: _categories.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) => ChoiceChip(label: Text(_categories[i]), selected: _category == i, onSelected: (_) => setState(() => _category = i)))),
            if (_query.isEmpty) SliverToBoxAdapter(child: _discoverHeader(provider.videos.length)),
            if (videos.isEmpty) SliverFillRemaining(hasScrollBody: false, child: _empty()),
            if (videos.isNotEmpty) SliverPadding(padding: const EdgeInsets.all(6), sliver: SliverGrid.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 6, mainAxisSpacing: 8, childAspectRatio: .66), itemCount: videos.length, itemBuilder: (_, i) => _VideoCard(video: videos[i], onTap: () { final index = provider.videos.indexWhere((v) => v.id == videos[i].id); if (index >= 0) provider.setCurrentIndex(index); Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPage(video: videos[i]))); }))),
          ]),
        );
      }),
    );
  }

  Widget _searchBox() => TextField(controller: _controller, focusNode: _focus, textDirection: TextDirection.rtl, decoration: InputDecoration(hintText: 'ابحث في فيديوهاتك...', prefixIcon: const Icon(Icons.search_rounded), suffixIcon: _query.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: () { _controller.clear(); setState(() => _query = ''); }), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)), onChanged: (v) => setState(() => _query = v.trim().toLowerCase()));

  List<VideoModel> _filtered(List<VideoModel> source) {
    var list = [...source];
    if (_query.isNotEmpty) list = list.where((v) => '${v.caption ?? ''} ${v.user?.username ?? ''}'.toLowerCase().contains(_query)).toList();
    if (_category == 1) list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (_category == 2) list.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
    if (_category == 3) list = list.where((v) => v.isSaved).toList();
    return list;
  }

  Widget _discoverHeader(int count) => Padding(padding: const EdgeInsets.fromLTRB(18, 12, 18, 8), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('اكتشف محتواك', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), Text('$count فيديو متاح في مكتبتك', style: const TextStyle(color: Colors.grey))])), Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .1), shape: BoxShape.circle), child: const Icon(Icons.explore_rounded, color: AppColors.primary))]));

  Widget _empty() => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(_query.isEmpty ? Icons.video_library_outlined : Icons.search_off_rounded, size: 72, color: Colors.grey), const SizedBox(height: 14), Text(_query.isEmpty ? 'لا توجد فيديوهات بعد' : 'لا توجد نتائج', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text(_query.isEmpty ? 'حدّث مكتبة وسائط الهاتف ليظهر المحتوى هنا.' : 'جرّب كلمة بحث أخرى.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey))])));
}

class _VideoCard extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;
  const _VideoCard({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(14), onTap: onTap, child: ClipRRect(borderRadius: BorderRadius.circular(14), child: Stack(fit: StackFit.expand, children: [
    _Thumbnail(path: video.videoUrl),
    const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87]))),
    const Positioned(right: 9, bottom: 9, child: DecoratedBox(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Padding(padding: EdgeInsets.all(7), child: Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 20)))),
    Positioned(left: 9, right: 9, bottom: 8, child: Text(video.caption ?? 'فيديو', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
  ]))));
}

class _Thumbnail extends StatelessWidget {
  final String path;
  const _Thumbnail({required this.path});
  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http')) return Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback());
    return FutureBuilder<String?>(future: VideoThumbnailService.instance.getThumbnailPath(path), builder: (_, snap) {
      if (snap.hasData && snap.data!.isNotEmpty) return Image.file(File(snap.data!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback());
      return _fallback();
    });
  }
  Widget _fallback() => Container(color: AppColors.dark, child: const Center(child: Icon(Icons.video_file_rounded, color: Colors.white54, size: 42)));
}
