import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';
import '../../models/video/video_model.dart';
import '../../providers/feed_provider.dart';
import '../../services/video_thumbnail_service.dart';
import '../../widgets/video/video_page.dart';

class MediaBrowserScreen extends StatefulWidget {
  const MediaBrowserScreen({super.key});

  @override
  State<MediaBrowserScreen> createState() => _MediaBrowserScreenState();
}

class _MediaBrowserScreenState extends State<MediaBrowserScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _sort = 'الأحدث';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('وسائط الهاتف'),
        actions: [
          Consumer<VideoProvider>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: provider.isRefreshing
                    ? null
                    : provider.refreshDeviceVideos,
                icon: provider.isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync_rounded),
              );
            },
          ),
        ],
      ),
      body: Consumer<VideoProvider>(
        builder: (context, provider, child) {
          final videos = _prepare(provider.videos);

          if (provider.isLoading && provider.videos.isEmpty) {
            return const _MediaLoadingGrid();
          }

          return RefreshIndicator(
            onRefresh: provider.refreshDeviceVideos,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildSearchField()),
                SliverToBoxAdapter(child: _buildSortRow(videos.length)),
                if (videos.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(provider),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(5),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        return _MediaTile(
                          video: videos[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _MediaViewer(
                                  videos: videos,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _query = value.trim().toLowerCase());
        },
        decoration: InputDecoration(
          hintText: 'ابحث في الفيديوهات...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  icon: const Icon(Icons.clear_rounded),
                ),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSortRow(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(
            '$count فيديو',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _chooseSort,
            icon: const Icon(Icons.sort_rounded),
            label: Text(_sort),
          ),
        ],
      ),
    );
  }

  List<VideoModel> _prepare(List<VideoModel> source) {
    final filtered = source.where((video) {
      if (_query.isEmpty) return true;
      final caption = video.caption ?? '';
      return caption.toLowerCase().contains(_query);
    }).toList();

    if (_sort == 'الأحدث') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_sort == 'الأقدم') {
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (_sort == 'المشاهدات') {
      filtered.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
    }

    return filtered;
  }

  Future<void> _chooseSort() async {
    final value = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        const options = ['الأحدث', 'الأقدم', 'المشاهدات'];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'ترتيب الوسائط',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              ...options.map(
                (option) => ListTile(
                  title: Text(option),
                  trailing: _sort == option
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(context, option),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (value != null && mounted) {
      setState(() => _sort = value);
    }
  }

  Widget _buildEmptyState(VideoProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.video_library_outlined, size: 76, color: Colors.grey),
            const SizedBox(height: 14),
            Text(
              _query.isEmpty ? 'لا توجد فيديوهات' : 'لا توجد نتائج',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'سيتم اكتشاف فيديوهات الهاتف تلقائيًا بعد منح إذن الوسائط.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            if (_query.isEmpty) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: provider.refreshDeviceVideos,
                icon: const Icon(Icons.sync),
                label: const Text('تحديث المكتبة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;

  const _MediaTile({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Thumbnail(path: video.videoUrl),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
          Positioned(
            right: 5,
            bottom: 5,
            child: Row(
              children: [
                const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 15),
                const SizedBox(width: 2),
                Text(
                  video.formatViews(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String path;

  const _Thumbnail({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    }

    return FutureBuilder<String?>(
      future: VideoThumbnailService.instance.getThumbnailPath(path),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Image.file(
            File(snapshot.data!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _fallback(),
          );
        }
        return _fallback();
      },
    );
  }

  Widget _fallback() {
    return const ColoredBox(
      color: Color(0xFF102624),
      child: Center(
        child: Icon(Icons.video_file_rounded, color: Colors.white54, size: 28),
      ),
    );
  }
}

class _MediaLoadingGrid extends StatelessWidget {
  const _MediaLoadingGrid();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.black12,
      highlightColor: Colors.white70,
      child: GridView.builder(
        padding: const EdgeInsets.all(5),
        itemCount: 18,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemBuilder: (context, index) => const ColoredBox(color: Colors.white),
      ),
    );
  }
}

class _MediaViewer extends StatefulWidget {
  final List<VideoModel> videos;
  final int initialIndex;

  const _MediaViewer({required this.videos, required this.initialIndex});

  @override
  State<_MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<_MediaViewer> {
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _controller,
              itemCount: widget.videos.length,
              itemBuilder: (context, index) {
                final video = widget.videos[index];
                return VideoPage(key: ValueKey(video.id), video: video);
              },
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
