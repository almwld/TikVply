import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../models/video/video_model.dart';
import '../../providers/feed_provider.dart';
import '../../providers/video_settings_provider.dart';
import 'video_actions.dart';
import 'video_info.dart';

class VideoPage extends StatefulWidget {
  final VideoModel video;
  const VideoPage({super.key, required this.video});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  VideoPlayerController? _controller;
  bool _loading = true;
  String? _error;
  bool _showControls = true;
  bool _showLikeAnimation = false;
  Offset _likePosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  bool get _isNetwork => widget.video.videoUrl.startsWith('http://') || widget.video.videoUrl.startsWith('https://');

  Future<void> _initializeVideo() async {
    final old = _controller;
    if (old != null) await old.dispose();
    if (mounted) setState(() { _loading = true; _error = null; });

    try {
      final controller = _isNetwork
          ? VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl))
          : VideoPlayerController.file(File(widget.video.videoUrl));
      _controller = controller;
      await controller.initialize();
      final settings = context.read<VideoSettingsProvider>();
      await controller.setLooping(settings.loop);
      await controller.setVolume(settings.muted ? 0 : 1);
      if (settings.autoplay) await controller.play();
      if (!mounted) return;
      setState(() => _loading = false);
      await context.read<VideoProvider>().incrementViews(widget.video.id);
    } catch (e, stack) {
      debugPrint('TikVply video_player initialization failed: $e');
      debugPrintStack(stackTrace: stack);
      if (mounted) setState(() { _loading = false; _error = 'تعذر تشغيل هذا الفيديو'; });
    }
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    setState(() => _showControls = !_showControls);
    c.value.isPlaying ? c.pause() : c.play();
  }

  void _onDoubleTap(TapDownDetails details) {
    final provider = context.read<VideoProvider>();
    if (!widget.video.isLiked) provider.likeVideo(widget.video.id);
    setState(() { _showLikeAnimation = true; _likePosition = details.localPosition; });
    Future.delayed(const Duration(milliseconds: 700), () { if (mounted) setState(() => _showLikeAnimation = false); });
  }

  void _seekBy(int seconds) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    final target = c.value.position + Duration(seconds: seconds);
    final max = c.value.duration;
    c.seekTo(target < Duration.zero ? Duration.zero : (target > max ? max : target));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_loading) const _VideoLoadingShimmer() else if (_error != null) _errorView() else _playerView(),
          if (!_loading && _error == null) _overlay(),
          if (_showLikeAnimation) _likeAnimation(),
        ],
      ),
    );
  }

  Widget _playerView() {
    final c = _controller!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlay,
      onDoubleTapDown: _onDoubleTap,
      onDoubleTap: () {},
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity.abs() > 350) _seekBy(velocity < 0 ? 10 : -10);
      },
      child: Center(
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: c,
          builder: (_, value, __) {
            if (!value.isInitialized) return const _VideoLoadingShimmer();
            return FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(width: value.size.width, height: value.size.height, child: VideoPlayer(c)),
            );
          },
        ),
      ),
    );
  }

  Widget _overlay() {
    final c = _controller!;
    return Stack(children: [
      const Positioned(top: 0, left: 0, right: 0, child: IgnorePointer(child: _TopGradient())),
      Positioned(left: 12, right: 78, bottom: 92, child: IgnorePointer(child: VideoInfo(video: widget.video))),
      Positioned(right: 10, bottom: 92, child: VideoActions(video: widget.video)),
      Positioned(left: 12, right: 12, bottom: 12, child: ValueListenableBuilder<VideoPlayerValue>(valueListenable: c, builder: (_, value, __) {
        if (!value.isInitialized) return const SizedBox.shrink();
        return Row(children: [
          IconButton(icon: Icon(value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white), onPressed: () => value.isPlaying ? c.pause() : c.play()),
          IconButton(icon: const Icon(Icons.replay_10_rounded, color: Colors.white), onPressed: () => _seekBy(-10)),
          Expanded(child: VideoProgressIndicator(c, allowScrubbing: true, padding: const EdgeInsets.symmetric(horizontal: 4), colors: VideoProgressColors(playedColor: AppColors.primary, bufferedColor: Colors.white38, backgroundColor: Colors.white24))),
          IconButton(icon: const Icon(Icons.forward_10_rounded, color: Colors.white), onPressed: () => _seekBy(10)),
        ]);
      })
    ]);
  }

  Widget _errorView() => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.video_file_rounded, color: Colors.white54, size: 64),
    const SizedBox(height: 14),
    Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
    const SizedBox(height: 18),
    FilledButton.icon(onPressed: _initializeVideo, icon: const Icon(Icons.refresh), label: const Text('إعادة المحاولة')),
  ]));

  Widget _likeAnimation() => Positioned(left: _likePosition.dx - 50, top: _likePosition.dy - 50, child: TweenAnimationBuilder<double>(tween: Tween(begin: .4, end: 1.15), duration: const Duration(milliseconds: 450), curve: Curves.elasticOut, builder: (_, scale, child) => Transform.scale(scale: scale, child: child), child: const Icon(Icons.favorite_rounded, color: AppColors.secondary, size: 100)));
}

class _TopGradient extends StatelessWidget {
  const _TopGradient();
  @override
  Widget build(BuildContext context) => Container(height: 120, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black54, Colors.transparent])));
}

class _VideoLoadingShimmer extends StatelessWidget {
  const _VideoLoadingShimmer();
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: const Color(0xFF111111),
    highlightColor: const Color(0xFF303030),
    child: Stack(fit: StackFit.expand, children: [
      const ColoredBox(color: Color(0xFF171717)),
      Align(alignment: Alignment.center, child: Container(width: 82, height: 82, decoration: const BoxDecoration(color: Color(0xFF292929), shape: BoxShape.circle))),
      Positioned(left: 16, right: 90, bottom: 100, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 190, height: 14, decoration: BoxDecoration(color: Color(0xFF292929), borderRadius: BorderRadius.all(Radius.circular(8)))), SizedBox(height: 10), Container(width: 130, height: 12, decoration: BoxDecoration(color: Color(0xFF292929), borderRadius: BorderRadius.all(Radius.circular(8))))])),
      Positioned(right: 14, bottom: 130, child: Column(children: [for (var i = 0; i < 4; i++) Padding(padding: const EdgeInsets.only(bottom: 14), child: Container(width: 42, height: 42, decoration: const BoxDecoration(color: Color(0xFF292929), shape: BoxShape.circle)))])),
    ]),
  );
}
