import 'package:av_player/av_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  late final AVPlayerController _controller;
  bool _initialized = false;

  VideoSettingsProvider get _settings => context.read<VideoSettingsProvider>();

  @override
  void initState() {
    super.initState();
    _controller = AVPlayerController(_sourceFor(widget.video.videoUrl));
    _initialize();
  }

  AVVideoSource _sourceFor(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return AVVideoSource.network(path);
    }
    return AVVideoSource.file(path);
  }

  Future<void> _initialize() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(_settings.loop);
      await _controller.setVolume(_settings.muted ? 0 : 1);
      await _controller.setPlaybackSpeed(_settings.playbackSpeed);
      await _controller.setNotificationEnabled(true);
      await _controller.setMediaMetadata(AVMediaMetadata(
        title: widget.video.caption.isEmpty ? 'TikVply' : widget.video.caption,
        artist: 'TikVply',
        album: 'فيديوهات الهاتف',
      ));
      if (_settings.autoplay) await _controller.play();
      if (!mounted) return;
      setState(() => _initialized = true);
      await context.read<VideoProvider>().incrementViews(widget.video.id);
    } catch (error) {
      debugPrint('TikVply AV playback initialization failed: $error');
      if (mounted) setState(() => _initialized = false);
    }
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (!_initialized)
            const Center(child: CircularProgressIndicator(color: AppColors.primary))
          else
            AVVideoPlayer(
              _controller,
              showControls: true,
              gestureConfig: const AVGestureConfig(
                doubleTapToSeek: true,
                seekDuration: Duration(seconds: 10),
                longPressSpeed: true,
                longPressSpeedMultiplier: 2.0,
                horizontalSwipeToSeek: true,
              ),
            ),
          if (_initialized) _buildOverlay(),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Stack(
      children: [
        Positioned(
          left: 12,
          right: 82,
          bottom: 108,
          child: IgnorePointer(child: VideoInfo(video: widget.video)),
        ),
        Positioned(
          right: 12,
          bottom: 108,
          child: VideoActions(video: widget.video),
        ),
      ],
    );
  }
}
