import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/feed_provider.dart';
import '../../services/video_thumbnail_service.dart';
import '../../widgets/video/video_page.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark, statusBarBrightness: Brightness.light, systemNavigationBarIconBrightness: Brightness.dark),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('اكتشف')),
          body: Consumer<VideoProvider>(builder: (context, provider, _) {
            final list = provider.videos.where((v) => query.isEmpty || '${v.caption ?? ''} ${v.user?.username ?? ''} ${v.hashtags.join(' ')}'.toLowerCase().contains(query)).toList();
            if (provider.isLoading && list.isEmpty) return const _DiscoverShimmer();
            return RefreshIndicator(
              onRefresh: provider.refreshDeviceVideos,
              child: Column(children: [
                Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 8), child: TextField(onChanged: (v) => setState(() => query = v.trim().toLowerCase()), textInputAction: TextInputAction.search, decoration: InputDecoration(hintText: 'ابحث عن فيديو...', prefixIcon: const Icon(Icons.search_rounded), suffixIcon: query.isEmpty ? null : IconButton(onPressed: () => setState(() => query = ''), icon: const Icon(Icons.clear_rounded)), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)))),
                Expanded(child: list.isEmpty ? ListView(physics: const AlwaysScrollableScrollPhysics(), children: const [SizedBox(height: 150), Center(child: Icon(Icons.search_off_rounded, size: 64, color: Colors.grey)), SizedBox(height: 12), Center(child: Text('لا توجد نتائج', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)))] ) : GridView.builder(padding: const EdgeInsets.all(6), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: .68), itemCount: list.length, itemBuilder: (context, i) { final video = list[i]; return InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPage(video: video))), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: _Thumb(path: video.videoUrl))); })),
              ]),
            );
          }),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String path;
  const _Thumb({required this.path});
  @override Widget build(BuildContext context) {
    if (path.startsWith('http')) return Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback());
    return FutureBuilder<String?>(future: VideoThumbnailService.instance.getThumbnailPath(path), builder: (_, s) => s.hasData && s.data!.isNotEmpty ? Image.file(File(s.data!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback()) : _fallback());
  }
  Widget _fallback() => const ColoredBox(color: Color(0xFF102624), child: Center(child: Icon(Icons.video_file_rounded, color: Colors.white54, size: 40)));
}

class _DiscoverShimmer extends StatelessWidget {
  const _DiscoverShimmer();
  @override Widget build(BuildContext context) => Shimmer.fromColors(baseColor: Colors.black12, highlightColor: Colors.white70, child: GridView.builder(padding: const EdgeInsets.all(6), itemCount: 10, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: .68), itemBuilder: (_, __) => const Card()));
}
