import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('اكتشف')),
      body: Consumer<VideoProvider>(builder: (context, provider, _) {
        final list = provider.videos.where((v) => query.isEmpty || '${v.caption ?? ''} ${v.user?.username ?? ''}'.toLowerCase().contains(query)).toList();
        if (provider.isLoading && list.isEmpty) return const Center(child: CircularProgressIndicator());
        return RefreshIndicator(
          onRefresh: provider.refreshDeviceVideos,
          child: Column(children: [
            Padding(padding: const EdgeInsets.all(12), child: TextField(onChanged: (v) => setState(() => query = v.trim().toLowerCase()), decoration: const InputDecoration(hintText: 'ابحث عن فيديو...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()))),
            Expanded(child: list.isEmpty ? const Center(child: Text('لا توجد نتائج')) : GridView.builder(padding: const EdgeInsets.all(6), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: .68), itemCount: list.length, itemBuilder: (context, i) { final video = list[i]; return InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPage(video: video))), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: _Thumb(path: video.videoUrl))); })),
          ]),
        );
      }),
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
