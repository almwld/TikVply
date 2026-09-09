import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VideoProvider>().refreshDeviceVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('وسائط الهاتف'),
        centerTitle: false,
        actions: [
          Consumer<VideoProvider>(
            builder: (_, provider, __) => IconButton(
              tooltip: 'تحديث الوسائط',
              onPressed: provider.isRefreshing ? null : provider.refreshDeviceVideos,
              icon: provider.isRefreshing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync_rounded),
            ),
          ),
        ],
      ),
      body: Consumer<VideoProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.videos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.videos.isEmpty) {
            return _empty(context, provider);
          }
          return RefreshIndicator(
            onRefresh: provider.refreshDeviceVideos,
            child: GridView.builder(
              padding: const EdgeInsets.all(3),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: provider.videos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                childAspectRatio: .72,
              ),
              itemBuilder: (_, index) {
                final video = provider.videos[index];
                return _MediaTile(
                  path: video.videoUrl,
                  index: index,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _MediaViewerScreen(initialIndex: index),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _empty(BuildContext context, VideoProvider provider) {
    return RefreshIndicator(
      onRefresh: provider.refreshDeviceVideos,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * .25),
          Icon(Icons.video_library_rounded, size: 82, color: AppColors.primary.withValues(alpha: .75)),
          const SizedBox(height: 18),
          const Center(child: Text('لا توجد فيديوهات متاحة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'يقرأ التطبيق مكتبة فيديوهات الهاتف تلقائيًا بعد منح إذن الوصول. لا تحتاج إلى اختيار الملفات واحدًا واحدًا.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.6),
            ),
          ),
          const SizedBox(height: 20),
          Center(child: FilledButton.icon(onPressed: provider.refreshDeviceVideos, icon: const Icon(Icons.sync), label: const Text('تحديث المكتبة'))),
        ],
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  final String path;
  final int index;
  final VoidCallback onTap;

  const _MediaTile({required this.path, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _VideoThumbnail(path: path),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black38],
              ),
            ),
          ),
          const Positioned(
            bottom: 7,
            right: 7,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.black60, shape: BoxShape.circle),
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
          Positioned(
            top: 5,
            left: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  final String path;

  const _VideoThumbnail({required this.path});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: VideoThumbnailService.instance.getThumbnailPath(path),
      builder: (context, snapshot) {
        final thumbnailPath = snapshot.data;
        if (thumbnailPath != null && thumbnailPath.isNotEmpty) {
          return Image.file(
            File(thumbnailPath),
            fit: BoxFit.cover,
            cacheWidth: 420,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _fallback(),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ColoredBox(
            color: Color(0xFF102624),
            child: Center(
              child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }
        return _fallback();
      },
    );
  }

  Widget _fallback() {
    return const ColoredBox(
      color: Color(0xFF102624),
      child: Center(child: Icon(Icons.video_file_rounded, color: Colors.white54, size: 30)),
    );
  }
}

class _MediaViewerScreen extends StatefulWidget {
  final int initialIndex;
  const _MediaViewerScreen({required this.initialIndex});

  @override
  State<_MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<_MediaViewerScreen> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videos = context.watch<VideoProvider>().videos;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              scrollDirection: Axis.vertical,
              itemCount: videos.length,
              itemBuilder: (_, index) => VideoPage(key: ValueKey(videos[index].id), video: videos[index]),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
