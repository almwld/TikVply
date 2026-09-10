import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/feed_provider.dart';
import '../../services/video_thumbnail_service.dart';
import '../../widgets/video/video_page.dart';

class MediaBrowserScreen extends StatefulWidget {
  const MediaBrowserScreen({super.key});
  @override
  State<MediaBrowserScreen> createState() => _MediaBrowserScreenState();
}

class _MediaBrowserScreenState extends State<MediaBrowserScreen> {
  String _sort = 'الأحدث';
  String _query = '';
  final _search = TextEditingController();

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('وسائط الهاتف'), actions: [Consumer<VideoProvider>(builder: (_, p, __) => IconButton(tooltip: 'تحديث', onPressed: p.isRefreshing ? null : p.refreshDeviceVideos, icon: p.isRefreshing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.sync_rounded))) ]),
      body: Consumer<VideoProvider>(builder: (context, provider, _) {
        var videos = [...provider.videos];
        if (_query.isNotEmpty) videos = videos.where((v) => (v.caption ?? '').toLowerCase().contains(_query.toLowerCase())).toList();
        if (_sort == 'الأحدث') videos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (_sort == 'الأقدم') videos.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        if (_sort == 'المشاهدات') videos.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
        if (provider.isLoading && provider.videos.isEmpty) return const _MediaLoadingGrid();
        return RefreshIndicator(onRefresh: provider.refreshDeviceVideos, child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 6), child: Row(children: [Expanded(child: TextField(controller: _search, onChanged: (v) => setState(() => _query = v), decoration: InputDecoration(hintText: 'ابحث في الوسائط...', prefixIcon: const Icon(Icons.search_rounded), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),), const SizedBox(width: 8), IconButton.filledTonal(onPressed: () => _pickSort(), icon: const Icon(Icons.tune_rounded))]))),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [Text('${videos.length} فيديو', style: const TextStyle(fontWeight: FontWeight.w800)), const Spacer(), Text(_sort, style: const TextStyle(color: Colors.grey))]))),
          if (videos.isEmpty) SliverFillRemaining(hasScrollBody: false, child: _empty(provider)) else SliverPadding(padding: const EdgeInsets.all(4), sliver: SliverGrid.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 3, childAspectRatio: .68), itemCount: videos.length, itemBuilder: (_, i) => _MediaTile(video: videos[i], index: i, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _MediaViewer(videos: videos, initialIndex: i))))),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ]));
      }),
    );
  }

  Future<void> _pickSort() async {
    final value = await showModalBottomSheet<String>(context: context, showDragHandle: true, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [const ListTile(title: Text('ترتيب الوسائط', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), for (final x in ['الأحدث', 'الأقدم', 'المشاهدات']) ListTile(title: Text(x), trailing: _sort == x ? const Icon(Icons.check, color: AppColors.primary) : null, onTap: () => Navigator.pop(context, x)), const SizedBox(height: 8)])));
    if (value != null && mounted) setState(() => _sort = value);
  }

  Widget _empty(VideoProvider provider) => Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.video_library_outlined, size: 76, color: Colors.grey), const SizedBox(height: 14), Text(_query.isEmpty ? 'لا توجد فيديوهات' : 'لا توجد نتائج', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 8), const Text('سيتم اكتشاف فيديوهات الهاتف تلقائيًا بعد منح إذن الوسائط.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)), const SizedBox(height: 18), if (_query.isEmpty) FilledButton.icon(onPressed: provider.refreshDeviceVideos, icon: const Icon(Icons.sync), label: const Text('تحديث المكتبة'))])));
}

class _MediaTile extends StatelessWidget {
  final dynamic video;
  final int index;
  final VoidCallback onTap;
  const _MediaTile({required this.video, required this.index, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, child: Stack(fit: StackFit.expand, children: [
    _Thumbnail(path: video.videoUrl),
    const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black54]))),
    Positioned(right: 5, bottom: 5, child: Row(children: [const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 15), const SizedBox(width: 2), Text(video.formatViews(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))])),
    Positioned(left: 5, top: 5, child: Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)), child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 9)))),
  ]));
}

class _Thumbnail extends StatelessWidget {
  final String path;
  const _Thumbnail({required this.path});
  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http')) return Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback());
    return FutureBuilder<String?>(future: VideoThumbnailService.instance.getThumbnailPath(path), builder: (_, s) => s.hasData && s.data!.isNotEmpty ? Image.file(File(s.data!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback()) : _fallback());
  }
  Widget _fallback() => const ColoredBox(color: Color(0xFF102624), child: Center(child: Icon(Icons.video_file_rounded, color: Colors.white54, size: 28)));
}

class _MediaLoadingGrid extends StatelessWidget {
  const _MediaLoadingGrid();
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(baseColor: const Color(0xFFE5E9E8), highlightColor: const Color(0xFFF7FAF9), child: GridView.builder(padding: const EdgeInsets.all(4), itemCount: 18, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 3), itemBuilder: (_, __) => const ColoredBox(color: Colors.white)));
}

class _MediaViewer extends StatelessWidget {
  final List videos;
  final int initialIndex;
  const _MediaViewer({required this.videos, required this.initialIndex});
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black, body: SafeArea(child: Stack(children: [PageView.builder(scrollDirection: Axis.vertical, controller: PageController(initialPage: initialIndex), itemCount: videos.length, itemBuilder: (_, i) => VideoPage(key: ValueKey(videos[i].id), video: videos[i])), Positioned(top: 4, right: 4, child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30)))]));
}
