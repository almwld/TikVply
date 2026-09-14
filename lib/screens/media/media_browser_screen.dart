import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../models/video/video_model.dart';
import '../../providers/feed_provider.dart';
import '../../providers/video_settings_provider.dart';
import '../../services/video_thumbnail_service.dart';
import '../../widgets/app_bar/tikvply_app_bar.dart';
import '../../widgets/video/video_page.dart';

class MediaBrowserScreen extends StatefulWidget {
  const MediaBrowserScreen({super.key});
  @override State<MediaBrowserScreen> createState() => _MediaBrowserScreenState();
}

class _MediaBrowserScreenState extends State<MediaBrowserScreen> with WidgetsBindingObserver {
  final _searchController = TextEditingController();
  String _query = '';
  String _sort = 'الأحدث';
  Timer? _resumeRefreshDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshIfNeeded(force: true));
  }

  Future<void> _refreshIfNeeded({bool force = false}) async {
    if (!mounted) return;
    final provider = context.read<VideoProvider>();
    if (!force && (provider.isRefreshing || provider.isLoading)) return;
    await provider.refreshDeviceVideos();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resumeRefreshDebounce?.cancel();
      _resumeRefreshDebounce = Timer(const Duration(milliseconds: 350), () => _refreshIfNeeded());
    }
  }

  @override
  void dispose() {
    _resumeRefreshDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: TikVplyAppBar(
            title: 'وسائط الهاتف',
            actions: [Consumer<VideoProvider>(builder: (_, provider, __) => IconButton(
              tooltip: 'تحديث المكتبة',
              onPressed: provider.isRefreshing ? null : () => _refreshIfNeeded(force: true),
              icon: provider.isRefreshing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync_rounded),
            ))],
          ),
          body: Consumer<VideoProvider>(builder: (_, provider, __) {
            final videos = _prepare(provider.videos);
            if (provider.isLoading && provider.videos.isEmpty) return const _MediaLoadingGrid();
            return RefreshIndicator(
              onRefresh: () => _refreshIfNeeded(force: true),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _searchField()),
                  SliverToBoxAdapter(child: _sortRow(videos.length)),
                  if (videos.isEmpty)
                    SliverFillRemaining(hasScrollBody: false, child: _emptyState(provider))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(5),
                      sliver: SliverGrid.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          childAspectRatio: .68,
                        ),
                        itemCount: videos.length,
                        itemBuilder: (_, index) => _MediaTile(
                          video: videos[index],
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => _MediaViewer(videos: videos, initialIndex: index),
                          )),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _searchField() => Padding(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
    child: TextField(
      controller: _searchController,
      textDirection: TextDirection.rtl,
      onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
      decoration: InputDecoration(
        hintText: 'ابحث في الفيديوهات...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _query.isEmpty ? null : IconButton(
          onPressed: () { _searchController.clear(); setState(() => _query = ''); },
          icon: const Icon(Icons.clear_rounded),
        ),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    ),
  );

  Widget _sortRow(int count) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Row(children: [
      Text('$count فيديو', style: const TextStyle(fontWeight: FontWeight.w800)),
      const Spacer(),
      TextButton.icon(onPressed: _chooseSort, icon: const Icon(Icons.sort_rounded), label: Text(_sort)),
    ]),
  );

  List<VideoModel> _prepare(List<VideoModel> source) {
    final filtered = source.where((v) => _query.isEmpty || '${v.caption ?? ''} ${v.user?.username ?? ''}'.toLowerCase().contains(_query)).toList();
    if (_sort == 'الأحدث') filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (_sort == 'الأقدم') filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (_sort == 'المشاهدات') filtered.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
    return filtered;
  }

  Future<void> _chooseSort() async {
    final value = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(title: Text('ترتيب الوسائط', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
          ...['الأحدث', 'الأقدم', 'المشاهدات'].map((option) => ListTile(
            title: Text(option),
            trailing: _sort == option ? const Icon(Icons.check, color: AppColors.primary) : null,
            onTap: () => Navigator.of(sheetContext).pop(option),
          )),
          const SizedBox(height: 8),
        ],
      )),
    );
    if (value != null && mounted) setState(() => _sort = value);
  }

  Widget _emptyState(VideoProvider provider) => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.video_library_outlined, size: 76, color: Colors.grey),
        const SizedBox(height: 14),
        Text(_query.isEmpty ? (provider.error ?? 'لا توجد فيديوهات') : 'لا توجد نتائج', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(provider.error != null ? 'امنح TikVply إذن الصور والفيديوهات الكامل ثم اضغط تحديث.' : 'سيتم اكتشاف فيديوهات الهاتف تلقائيًا.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        if (_query.isEmpty) ...[
          const SizedBox(height: 18),
          FilledButton.icon(onPressed: () => _refreshIfNeeded(force: true), icon: const Icon(Icons.sync), label: const Text('تحديث المكتبة')),
        ],
      ]),
    ),
  );
}

class _MediaTile extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;
  const _MediaTile({required this.video, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Stack(fit: StackFit.expand, children: [
      _Thumbnail(path: video.videoUrl),
      const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black54]))),
      Positioned(right: 5, bottom: 5, child: Row(children: [const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 15), const SizedBox(width: 2), Text(video.formatViews(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))])),
    ]),
  );
}

class _Thumbnail extends StatefulWidget {
  final String path;
  const _Thumbnail({required this.path});
  @override State<_Thumbnail> createState() => _ThumbnailState();
}

class _ThumbnailState extends State<_Thumbnail> with AutomaticKeepAliveClientMixin {
  late Future<String?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<String?> _load() async {
    if (widget.path.startsWith('http')) return widget.path;
    return VideoThumbnailService.instance.getThumbnailPath(widget.path);
  }

  @override
  void didUpdateWidget(covariant _Thumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<String?>(
      future: _future,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ColoredBox(color: Color(0xFF101820), child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54))));
        }
        final source = snapshot.data;
        if (source != null && source.isNotEmpty) {
          final image = source.startsWith('http') ? Image.network(source, fit: BoxFit.cover) : Image.file(File(source), fit: BoxFit.cover);
          return image;
        }
        return const ColoredBox(color: Color(0xFF102624), child: Center(child: Icon(Icons.video_file_rounded, color: Colors.white54, size: 28)));
      },
    );
  }

  @override bool get wantKeepAlive => true;
}

class _MediaLoadingGrid extends StatelessWidget {
  const _MediaLoadingGrid();
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: Colors.black12,
    highlightColor: Colors.white70,
    child: GridView.builder(padding: const EdgeInsets.all(5), itemCount: 18, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4), itemBuilder: (_, __) => const ColoredBox(color: Colors.white)),
  );
}

class _MediaViewer extends StatefulWidget {
  final List<VideoModel> videos;
  final int initialIndex;
  const _MediaViewer({required this.videos, required this.initialIndex});
  @override State<_MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<_MediaViewer> {
  late final PageController _controller;
  @override void initState() { super.initState(); _controller = PageController(initialPage: widget.initialIndex); }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  void _next() {
    if (!_controller.hasClients) return;
    final page = _controller.page?.round() ?? widget.initialIndex;
    if (page + 1 < widget.videos.length) {
      _controller.animateToPage(page + 1, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
    } else {
      Navigator.of(context).maybePop();
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: Stack(children: [
      PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _controller,
        itemCount: widget.videos.length,
        itemBuilder: (_, index) => VideoPage(
          key: ValueKey(widget.videos[index].id),
          video: widget.videos[index],
          onCompleted: context.read<VideoSettingsProvider>().autoNext ? _next : null,
        ),
      ),
      Positioned(top: MediaQuery.paddingOf(context).top + 4, right: 4, child: IconButton(tooltip: 'إغلاق', onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30))),
    ]),
  );
}
