import 'dart:async';
import 'package:av_player/av_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/video/video_model.dart';
import '../../providers/feed_provider.dart';
import '../../providers/video_settings_provider.dart';
import '../../services/video_playback_state_service.dart';
import 'video_actions.dart';
import 'video_info.dart';

class VideoPage extends StatefulWidget {
  final VideoModel video;
  const VideoPage({super.key, required this.video});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late final AVPlayerController _controller;
  final VideoPlaybackStateService _playbackState = VideoPlaybackStateService();
  Timer? _saveTimer;
  bool _initialized = false;
  bool _advanced = false;

  VideoSettingsProvider get _settings => context.read<VideoSettingsProvider>();

  @override
  void initState() {
    super.initState();
    _settings.addListener(_applySettings);
    _controller = AVPlayerController(_sourceFor(widget.video.videoUrl));
    _controller.addListener(_handlePlayerState);
    _initialize();
  }

  AVVideoSource _sourceFor(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return AVVideoSource.network(path);
    return AVVideoSource.file(path);
  }

  Future<void> _initialize() async {
    try {
      await _controller.initialize();
      await _applySettings();

      final state = _controller.value;
      await context.read<VideoProvider>().updateVideoMetadata(
        widget.video.id,
        duration: state.duration,
        aspectRatio: state.aspectRatio,
      );

      await _controller.setMediaMetadata(AVMediaMetadata(
        title: (widget.video.caption ?? '').trim().isEmpty ? 'TikVply' : widget.video.caption!,
        artist: 'TikVply',
        album: 'فيديوهات الهاتف',
      ));

      final savedPosition = await _playbackState.loadPosition(widget.video.id);
      if (savedPosition != null && savedPosition < state.duration) {
        await _controller.seekTo(savedPosition);
      } else if (savedPosition != null) {
        await _playbackState.clearPosition(widget.video.id);
      }

      if (_settings.autoplay) await _controller.play();
      if (!mounted) return;
      setState(() => _initialized = true);
      await context.read<VideoProvider>().incrementViews(widget.video.id);
    } catch (error, stackTrace) {
      debugPrint('TikVply AV playback initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) setState(() => _initialized = false);
    }
  }

  void _handlePlayerState() {
    if (!_controller.value.isInitialized) return;
    final state = _controller.value;
    if (state.position > Duration.zero) {
      _saveTimer ??= Timer.periodic(const Duration(seconds: 5), (_) => _savePosition());
    }
    if (state.isCompleted && !_settings.loop && !_advanced) {
      _advanced = true;
      unawaited(_savePosition(clear: true));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<VideoProvider>().nextVideo();
      });
    }
  }

  Future<void> _savePosition({bool clear = false}) async {
    if (clear) {
      await _playbackState.clearPosition(widget.video.id);
      return;
    }
    if (!_controller.value.isInitialized || _controller.value.isCompleted) return;
    await _playbackState.savePosition(widget.video.id, _controller.value.position);
  }

  Future<void> _applySettings() async {
    if (!_controller.value.isInitialized) return;
    await _controller.setLooping(_settings.loop);
    await _controller.setVolume(_settings.muted ? 0 : 1);
    await _controller.setPlaybackSpeed(_settings.playbackSpeed);
    await _controller.setNotificationEnabled(_settings.mediaNotifications);
    await _controller.setWakelock(_settings.keepScreenAwake);
  }

  @override
  void dispose() {
    unawaited(_savePosition());
    _saveTimer?.cancel();
    _settings.removeListener(_applySettings);
    _controller.removeListener(_handlePlayerState);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (!_initialized)
            const Center(child: CircularProgressIndicator(color: AppColors.primary))
          else
            _buildPlayer(),
          if (_initialized) _buildOverlay(),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    final settings = context.watch<VideoSettingsProvider>();
    final fit = switch (settings.fitMode) {
      VideoFitMode.cover => BoxFit.cover,
      VideoFitMode.contain => BoxFit.contain,
      VideoFitMode.fill => BoxFit.fill,
    };
    return FittedBox(
      fit: fit,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        child: AVVideoPlayer(
          _controller,
          showControls: true,
          gestureConfig: AVGestureConfig(
            doubleTapToSeek: settings.gesturesEnabled,
            seekDuration: const Duration(seconds: 10),
            longPressSpeed: settings.gesturesEnabled,
            longPressSpeedMultiplier: 2.0,
            horizontalSwipeToSeek: settings.gesturesEnabled,
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Stack(
      children: [
        Positioned(left: 12, right: 82, bottom: 108, child: IgnorePointer(child: VideoInfo(video: widget.video))),
        Positioned(right: 12, bottom: 108, child: VideoActions(video: widget.video)),
      ],
    );
  }
}
