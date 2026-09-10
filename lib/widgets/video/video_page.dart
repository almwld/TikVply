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

  VideoSettingsProvider get _settings => context.read<VideoSettingsProvider>();
  bool get _isNetwork => widget.video.videoUrl.startsWith('http://') || widget.video.videoUrl.startsWith('https://');

  @override
  void initState() {
    super.initState();
    _settings.addListener(_applySettings);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final previous = _controller;
    _controller = null;
    if (previous != null) await previous.dispose();
    if (mounted) setState(() { _loading = true; _error = null; });

    try {
      final source = _isNetwork
          ? VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl))
          : VideoPlayerController.file(File(widget.video.videoUrl));
      _controller = source;
      source.addListener(_playerListener);
      await source.initialize();
      await _applySettings();
      if (!mounted) return;
      setState(() => _loading = false);
      if (_settings.autoplay) await source.play();
      await context.read<VideoProvider>().incrementViews(widget.video.id);
    } catch (error, stackTrace) {
      debugPrint('TikVply stable video_player error: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) setState(() { _loading = false; _error = _errorText(error); });
    }
  }

  String _errorText(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('permission') || text.contains('access')) return 'لا يمكن الوصول إلى ملف الفيديو. تحقق من إذن الوسائط.';
    if (text.contains('source') || text.contains('format') || text.contains('codec')) return 'صيغة الفيديو غير مدعومة على هذا الجهاز.';
    return 'تعذر تشغيل الفيديو. اضغط إعادة المحاولة.';
  }

  void _playerListener() {
    final c = _controller;
    if (c == null || !mounted || !c.value.isInitialized) return;
    if (c.value.hasError && _error == null) {
      setState(() { _loading = false; _error = c.value.errorDescription ?? 'تعذر تشغيل الفيديو'; });
    }
  }

  Future<void> _applySettings() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    try {
      await c.setLooping(_settings.loop);
      await c.setVolume(_settings.muted ? 0 : 1);
      await c.setPlaybackSpeed(_settings.playbackSpeed);
    } catch (_) {}
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
    Future.delayed(const Duration(milliseconds: 650), () { if (mounted) setState(() => _showLikeAnimation = false); });
  }

  void _seekBy(int seconds) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    final target = c.value.position + Duration(seconds: seconds);
    final duration = c.value.duration;
    c.seekTo(target < Duration.zero ? Duration.zero : target > duration ? duration : target);
  }

  @override
  void dispose() {
    _settings.removeListener(_applySettings);
    final c = _controller;
    if (c != null) c.removeListener(_playerListener);
    c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.black,
    child: Stack(fit: StackFit.expand, children: [
      if (_loading) const _VideoLoadingShimmer()
      else if (_error != null) _errorView()
      else _playerView(),
      if (!_loading && _error == null) _overlay(),
      if (_showLikeAnimation) _likeAnimation(),
    ]),
  );

  Widget _playerView() {
    final c = _controller!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlay,
      onDoubleTapDown: _onDoubleTap,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity.abs() > 350) _seekBy(velocity < 0 ? 10 : -10);
      },
      child: Center(
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: c,
          builder: (_, value, __) {
            if (!value.isInitialized) return const _VideoLoadingShimmer();
            final aspect = value.aspectRatio > 0 ? value.aspectRatio : 9 / 16;
            final fit = switch (_settings.fitMode) {
              VideoFitMode.cover => BoxFit.cover,
              VideoFitMode.contain => BoxFit.contain,
              VideoFitMode.fill => BoxFit.fill,
            };
            return SizedBox.expand(child: FittedBox(fit: fit, clipBehavior: Clip.hardEdge, child: AspectRatio(aspectRatio: aspect, child: VideoPlayer(c))));
          },
        ),
      ),
    );
  }

  Widget _overlay() => Stack(children: [
    const Positioned(top: 0, left: 0, right: 0, child: IgnorePointer(child: _TopGradient())),
    Positioned(left: 12, right: 78, bottom: 92, child: IgnorePointer(child: VideoInfo(video: widget.video))),
    Positioned(right: 10, bottom: 92, child: VideoActions(video: widget.video)),
    Positioned(left: 12, right: 12, bottom: 12, child: ValueListenableBuilder<VideoPlayerValue>(valueListenable: _controller!, builder: (_, value, __) {
      if (!value.isInitialized || !_showControls) return const SizedBox.shrink();
      return Row(children: [
        IconButton(icon: Icon(value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white), onPressed: () => value.isPlaying ? _controller!.pause() : _controller!.play()),
        IconButton(icon: const Icon(Icons.replay_10_rounded, color: Colors.white), onPressed: () => _seekBy(-10)),
        Expanded(child: VideoProgressIndicator(_controller!, allowScrubbing: true, padding: const EdgeInsets.symmetric(horizontal: 4), colors: const VideoProgressColors(playedColor: AppColors.primary, bufferedColor: Colors.white38, backgroundColor: Colors.white24))),
        IconButton(icon: const Icon(Icons.forward_10_rounded, color: Colors.white), onPressed: () => _seekBy(10)),
      ]);
    })),
  ]);

  Widget _errorView() => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.video_file_rounded, color: Colors.white54, size: 64),
    const SizedBox(height: 14),
    Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
    const SizedBox(height: 18),
    FilledButton.icon(onPressed: _initializeVideo, icon: const Icon(Icons.refresh_rounded), label: const Text('إعادة المحاولة')),
  ])));

  Widget _likeAnimation() => Positioned(left: _likePosition.dx - 50, top: _likePosition.dy - 50, child: TweenAnimationBuilder<double>(tween: Tween(begin: .35, end: 1.15), duration: const Duration(milliseconds: 450), curve: Curves.elasticOut, builder: (_, scale, child) => Transform.scale(scale: scale, child: child), child: const Icon(Icons.favorite_rounded, color: AppColors.secondary, size: 100)));
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
    baseColor: const Color(0xFF101817),
    highlightColor: const Color(0xFF2B3836),
    period: const Duration(milliseconds: 1150),
    child: Stack(fit: StackFit.expand, children: [
      const ColoredBox(color: Color(0xFF171F1E)),
      Center(child: Container(width: 86, height: 86, decoration: const BoxDecoration(color: Color(0xFF26302F), shape: BoxShape.circle))),
      Positioned(left: 16, right: 88, bottom: 104, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 205, height: 15, decoration: BoxDecoration(color: Color(0xFF293331), borderRadius: BorderRadius.circular(8))),
        const SizedBox(height: 10),
        Container(width: 145, height: 12, decoration: BoxDecoration(color: Color(0xFF293331), borderRadius: BorderRadius.circular(8))),
        const SizedBox(height: 9),
        Container(width: 230, height: 9, decoration: BoxDecoration(color: Color(0xFF293331), borderRadius: BorderRadius.circular(6))),
      ])),
      Positioned(right: 14, bottom: 128, child: Column(children: [for (var i = 0; i < 4; i++) Padding(padding: const EdgeInsets.only(bottom: 15), child: Container(width: 45, height: 45, decoration: const BoxDecoration(color: Color(0xFF293331), shape: BoxShape.circle)))])),
      const Positioned(left: 14, right: 14, bottom: 18, child: SizedBox(height: 4, child: ColoredBox(color: Color(0xFF293331)))),
    ]),
  );
}
