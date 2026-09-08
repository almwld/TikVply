import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

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
  bool _ready = false;
  bool _controlsVisible = true;
  bool _likedAnimation = false;
  Offset _likePosition = Offset.zero;
  bool _fullscreen = false;
  Duration _lastPosition = Duration.zero;

  VideoSettingsProvider get _settings => context.read<VideoSettingsProvider>();

  @override
  void initState() {
    super.initState();
    _settings.addListener(_applySettings);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final path = widget.video.videoUrl;
    final controller = path.startsWith('http://') || path.startsWith('https://')
        ? VideoPlayerController.networkUrl(Uri.parse(path))
        : VideoPlayerController.file(File(path));
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(_settings.loop);
      await controller.setVolume(_settings.muted ? 0 : 1);
      await controller.setPlaybackSpeed(_settings.playbackSpeed);
      if (_settings.autoplay) {
        await controller.play();
      }
      if (!mounted) return;
      setState(() => _ready = true);
      await context.read<VideoProvider>().incrementViews(widget.video.id);
    } catch (e) {
      if (mounted) setState(() => _ready = false);
      debugPrint('Video initialization failed: $e');
    }
  }

  Future<void> _applySettings() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.setLooping(_settings.loop);
    await controller.setVolume(_settings.muted ? 0 : 1);
    await controller.setPlaybackSpeed(_settings.playbackSpeed);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _settings.removeListener(_applySettings);
    _controller?.dispose();
    if (_fullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }
    super.dispose();
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    setState(() => _controlsVisible = true);
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  void _toggleControls() => setState(() => _controlsVisible = !_controlsVisible);

  void _doubleTapLike(TapDownDetails details) {
    final provider = context.read<VideoProvider>();
    if (!widget.video.isLiked) provider.likeVideo(widget.video.id);
    setState(() {
      _likedAnimation = true;
      _likePosition = details.localPosition;
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _likedAnimation = false);
    });
  }

  void _seekBy(double seconds) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final target = controller.value.position + Duration(milliseconds: (seconds * 1000).round());
    final max = controller.value.duration;
    final clamped = target < Duration.zero ? Duration.zero : (target > max ? max : target);
    controller.seekTo(clamped);
    setState(() => _controlsVisible = true);
  }

  Future<void> _toggleFullscreen() async {
    _fullscreen = !_fullscreen;
    if (_fullscreen) {
      await SystemChrome.setPreferredOrientations(const [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleMute() => _settings.setMuted(!_settings.muted);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _settings.gesturesEnabled ? _toggleControls : null,
        onDoubleTapDown: _settings.gesturesEnabled ? _doubleTapLike : null,
        onDoubleTap: _settings.gesturesEnabled ? () {} : null,
        onLongPressStart: _settings.gesturesEnabled ? (_) async {
          final controller = _controller;
          if (controller != null && controller.value.isInitialized) await controller.setPlaybackSpeed(2.0);
        } : null,
        onLongPressEnd: _settings.gesturesEnabled ? (_) async {
          final controller = _controller;
          if (controller != null && controller.value.isInitialized) await controller.setPlaybackSpeed(_settings.playbackSpeed);
        } : null,
        onHorizontalDragUpdate: _settings.gesturesEnabled ? (details) {
          final controller = _controller;
          if (controller == null || !controller.value.isInitialized) return;
          final width = MediaQuery.sizeOf(context).width;
          final deltaSeconds = (details.primaryDelta ?? 0) / width * controller.value.duration.inSeconds * 0.9;
          _lastPosition = controller.value.position;
          _seekBy(deltaSeconds);
        } : null,
        child: Stack(fit: StackFit.expand, children: [
          _buildVideo(),
          if (_controlsVisible) _buildOverlays(),
          if (_likedAnimation) _buildLikeAnimation(),
        ]),
      ),
    );
  }

  Widget _buildVideo() {
    if (!_ready || _controller == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    final controller = _controller!;
    final aspect = controller.value.aspectRatio == 0 ? 9 / 16 : controller.value.aspectRatio;
    return ClipRect(
      child: _settings.fitMode == VideoFitMode.fill
          ? SizedBox.expand(child: VideoPlayer(controller))
          : FittedBox(
              fit: _settings.fitMode == VideoFitMode.contain ? BoxFit.contain : BoxFit.cover,
              alignment: Alignment.center,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.width / aspect,
                child: VideoPlayer(controller),
              ),
            ),
    );
  }

  Widget _buildOverlays() {
    final controller = _controller;
    final playing = controller?.value.isPlaying ?? false;
    return Stack(children: [
      Positioned.fill(child: IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: .48), Colors.transparent, Colors.black.withValues(alpha: .55)], stops: const [0, .48, 1]))))),
      Positioned(top: 0, left: 0, right: 0, child: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(children: [
          IconButton(onPressed: _toggleMute, icon: Icon(_settings.muted ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: Colors.white)),
          const Spacer(),
          IconButton(onPressed: _toggleFullscreen, icon: Icon(_fullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded, color: Colors.white)),
        ]),
      ))),
      if (_ready) Positioned(left: 12, right: 82, bottom: 100, child: VideoInfo(video: widget.video)),
      if (_ready) Positioned(right: 12, bottom: 100, child: VideoActions(video: widget.video)),
      Center(child: AnimatedOpacity(opacity: _controlsVisible ? 1 : 0, duration: const Duration(milliseconds: 160), child: GestureDetector(onTap: _togglePlayback, child: Container(
        width: 62, height: 62,
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: .42), shape: BoxShape.circle),
        child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 40),
      )))),
      if (_ready) Positioned(left: 10, right: 10, bottom: MediaQuery.paddingOf(context).bottom + 68, child: VideoProgressIndicator(
        controller!,
        allowScrubbing: true,
        colors: const VideoProgressColors(playedColor: Colors.white, bufferedColor: Colors.white38, backgroundColor: Colors.white24),
        padding: const EdgeInsets.symmetric(vertical: 6),
      )),
      Positioned(bottom: MediaQuery.paddingOf(context).bottom + 20, left: 14, right: 14, child: Row(children: [
        const Icon(Icons.speed_rounded, color: Colors.white70, size: 16),
        const SizedBox(width: 5),
        Text('${_settings.playbackSpeed}x', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(_formatDuration(controller?.value.position ?? Duration.zero), style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const Text(' / ', style: TextStyle(color: Colors.white38)),
        Text(_formatDuration(controller?.value.duration ?? Duration.zero), style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ])),
    ];
  }

  Widget _buildLikeAnimation() {
    return Positioned(left: _likePosition.dx - 50, top: _likePosition.dy - 50, child: TweenAnimationBuilder<double>(
      tween: Tween(begin: .45, end: 1.25), duration: const Duration(milliseconds: 420), curve: Curves.elasticOut,
      builder: (_, scale, __) => Transform.scale(scale: scale, child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 100)),
    ));
  }

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (value.inHours > 0) return '${value.inHours}:$minutes:$seconds';
    return '${value.inMinutes}:$seconds';
  }
}
