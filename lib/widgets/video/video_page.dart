import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../models/video/video_model.dart';
import '../../providers/feed_provider.dart';
import '../../providers/video_settings_provider.dart';
import '../../services/video_playback_state_service.dart';
import 'video_actions.dart';
import 'video_info.dart';

class VideoPage extends StatefulWidget {
  final VideoModel video;
  final VoidCallback? onCompleted;
  const VideoPage({super.key, required this.video, this.onCompleted});
  @override State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> with WidgetsBindingObserver {
  static const _platform = MethodChannel('com.tikvply/player');
  VideoPlayerController? _controller;
  final _playback = VideoPlaybackStateService();
  Timer? _saveTimer;
  Timer? _hideTimer;
  Timer? _sleepTimer;
  bool _loading = true;
  bool _showControls = true;
  bool _locked = false;
  bool _fullscreen = false;
  bool _inPip = false;
  bool _completionSent = false;
  bool _like = false;
  Offset _likePosition = Offset.zero;
  Offset? _gestureStart;
  double _startBrightness = .5;
  double _startVolume = 1;
  Duration? _a;
  Duration? _b;
  int? _sleepMinutes;

  VideoSettingsProvider get settings => context.read<VideoSettingsProvider>();
  bool get _network => widget.video.videoUrl.startsWith('http://') || widget.video.videoUrl.startsWith('https://');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    settings.addListener(_applySettings);
    _open();
  }

  Future<void> _open() async {
    final previous = _controller;
    _controller = null;
    _saveTimer?.cancel();
    _completionSent = false;
    if (previous != null) {
      previous.removeListener(_listener);
      await previous.dispose();
    }
    if (mounted) setState(() => _loading = true);
    try {
      final controller = _network
          ? VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl))
          : VideoPlayerController.file(File(widget.video.videoUrl));
      _controller = controller;
      controller.addListener(_listener);
      await controller.initialize();
      if (!controller.value.isInitialized || controller.value.duration <= Duration.zero) {
        throw StateError('invalid video');
      }
      await _applySettings();
      final saved = await _playback.loadPosition(widget.video.id);
      if (saved != null && saved > Duration.zero && saved < controller.value.duration - const Duration(seconds: 2)) {
        await controller.seekTo(saved);
      }
      if (!mounted) return;
      setState(() => _loading = false);
      if (settings.autoplay) await controller.play();
      _startSaving();
      _scheduleHide();
      final provider = context.read<VideoProvider>();
      await provider.updateVideoMetadata(widget.video.id, duration: controller.value.duration, aspectRatio: controller.value.aspectRatio);
      await provider.incrementViews(widget.video.id);
    } catch (error, stack) {
      debugPrint('TikVply player open failed: $error');
      debugPrintStack(stackTrace: stack);
      if (!mounted) return;
      setState(() => _loading = false);
      // No error screen: unreadable media is skipped silently when a next item exists.
      if (widget.onCompleted != null) {
        Future<void>.delayed(const Duration(milliseconds: 180), () {
          if (mounted && !_completionSent) {
            _completionSent = true;
            widget.onCompleted!();
          }
        });
      }
    }
  }

  void _listener() {
    final c = _controller;
    if (c == null || !mounted || !c.value.isInitialized) return;
    if (c.value.hasError) {
      if (!_completionSent && widget.onCompleted != null) {
        _completionSent = true;
        widget.onCompleted!();
      }
      return;
    }
    final position = c.value.position;
    final duration = c.value.duration;
    if (_a != null && _b != null && position >= _b! - const Duration(milliseconds: 100)) {
      c.seekTo(_a!);
      return;
    }
    if (!settings.loop && !_completionSent && duration > Duration.zero && position >= duration - const Duration(milliseconds: 250)) {
      _completionSent = true;
      _playback.clearPosition(widget.video.id);
      widget.onCompleted?.call();
    }
  }

  Future<void> _applySettings() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    try {
      await c.setLooping(settings.loop);
      await c.setVolume(settings.muted ? 0 : c.value.volume);
      await c.setPlaybackSpeed(settings.playbackSpeed);
      if (settings.keepScreenAwake && c.value.isPlaying) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (_) {}
  }

  void _startSaving() {
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final c = _controller;
      if (c != null && c.value.isInitialized && c.value.isPlaying) {
        _savePosition(c.value.position);
      }
    });
  }

  Future<void> _savePosition(Duration p) async {
    final duration = _controller?.value.duration ?? Duration.zero;
    if (p <= Duration.zero || duration <= Duration.zero || p >= duration) return;
    await _playback.savePosition(widget.video.id, p);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (state == AppLifecycleState.resumed && settings.keepScreenAwake && c?.value.isPlaying == true) {
      WakelockPlus.enable();
    }
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (c != null && c.value.isInitialized) {
        _savePosition(c.value.position);
        if (!_inPip) c.pause();
      }
      if (!_inPip) WakelockPlus.disable();
    }
  }

  void _togglePlay() {
    final c = _controller;
    if (_locked || c == null || !c.value.isInitialized) return;
    if (c.value.isPlaying) {
      c.pause();
      WakelockPlus.disable();
    } else {
      c.play();
      if (settings.keepScreenAwake) WakelockPlus.enable();
    }
    setState(() => _showControls = true);
    _scheduleHide();
  }

  void _tap() {
    if (_locked) return;
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    if (!_showControls || _locked) return;
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _seek(int seconds) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    final duration = c.value.duration;
    final target = c.value.position + Duration(seconds: seconds);
    c.seekTo(target < Duration.zero ? Duration.zero : target > duration ? duration : target);
    setState(() => _showControls = true);
    _scheduleHide();
  }

  void _doubleTap(TapDownDetails details) {
    if (_locked) return;
    final width = MediaQuery.sizeOf(context).width;
    if (details.localPosition.dx < width / 3) {
      _seek(-settings.skipSeconds);
      return;
    }
    if (details.localPosition.dx > width * 2 / 3) {
      _seek(settings.skipSeconds);
      return;
    }
    if (!widget.video.isLiked) context.read<VideoProvider>().likeVideo(widget.video.id);
    setState(() {
      _like = true;
      _likePosition = details.localPosition;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _like = false);
    });
  }

  Future<void> _verticalStart(DragStartDetails details) async {
    if (_locked || !settings.gesturesEnabled) return;
    _gestureStart = details.localPosition;
    _startVolume = _controller?.value.volume ?? 1;
    try {
      _startBrightness = await ScreenBrightness.instance.application;
    } catch (_) {
      _startBrightness = .5;
    }
  }

  void _verticalUpdate(DragUpdateDetails details) {
    if (_locked || !settings.gesturesEnabled || _gestureStart == null) return;
    final delta = -details.delta.dy / MediaQuery.sizeOf(context).height;
    if (_gestureStart!.dx < MediaQuery.sizeOf(context).width / 2) {
      ScreenBrightness.instance.setApplicationScreenBrightness((_startBrightness + delta).clamp(.05, 1.0).toDouble());
    } else {
      _controller?.setVolume((_startVolume + delta).clamp(0.0, 1.0).toDouble());
    }
    setState(() => _showControls = true);
  }

  void _verticalEnd(DragEndDetails details) {
    _gestureStart = null;
    _scheduleHide();
  }

  Future<void> _fullscreenToggle() async {
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

  Future<void> _pip() async {
    try {
      final available = await _platform.invokeMethod<bool>('isPipAvailable') ?? false;
      if (!available) return;
      _inPip = true;
      await _platform.invokeMethod('enterPip');
      await _controller?.play();
    } catch (_) {
      _inPip = false;
    }
  }

  void _lock() {
    _hideTimer?.cancel();
    setState(() {
      _locked = !_locked;
      _showControls = true;
    });
    if (!_locked) _scheduleHide();
  }

  void _sleep(int? minutes) {
    _sleepTimer?.cancel();
    _sleepMinutes = minutes;
    if (minutes != null) {
      _sleepTimer = Timer(Duration(minutes: minutes), () {
        _controller?.pause();
        _sleepMinutes = null;
        WakelockPlus.disable();
        if (mounted) setState(() {});
      });
    }
    setState(() {});
  }

  void _ab() {
    final position = _controller?.value.position ?? Duration.zero;
    if (_a == null) {
      setState(() {
        _a = position;
        _b = null;
      });
    } else if (_b == null && position > _a!) {
      setState(() => _b = position);
    } else {
      setState(() {
        _a = null;
        _b = null;
      });
    }
  }

  void _sleepMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('مؤقت النوم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            for (final minutes in [15, 30, 60, 90])
              ListTile(
                leading: const Icon(Icons.schedule, color: Colors.white),
                title: Text('$minutes دقيقة', style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(c);
                  _sleep(minutes);
                },
              ),
            ListTile(
              leading: const Icon(Icons.timer_off, color: Colors.white),
              title: const Text('إيقاف المؤقت', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(c);
                _sleep(null);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _hideTimer?.cancel();
    _sleepTimer?.cancel();
    final c = _controller;
    if (c != null && c.value.isInitialized) _savePosition(c.value.position);
    settings.removeListener(_applySettings);
    WidgetsBinding.instance.removeObserver(this);
    c?.removeListener(_listener);
    c?.dispose();
    WakelockPlus.disable();
    if (_fullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_loading || _controller == null || !_controller!.value.isInitialized)
              const _VideoLoadingShimmer()
            else
              _video(),
            if (!_loading && _controller != null && _controller!.value.isInitialized && !_locked) _controls(),
            if (_locked)
              Positioned(
                top: MediaQuery.paddingOf(context).top + 8,
                left: 8,
                child: IconButton(onPressed: _lock, tooltip: 'فتح القفل', icon: const Icon(Icons.lock_rounded, color: Colors.white)),
              ),
            if (_like)
              Positioned(left: _likePosition.dx - 50, top: _likePosition.dy - 50, child: const Icon(Icons.favorite_rounded, color: AppColors.secondary, size: 100)),
          ],
        ),
      ),
    );
  }

  Widget _video() {
    final c = _controller!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _tap,
      onDoubleTapDown: _doubleTap,
      onVerticalDragStart: _verticalStart,
      onVerticalDragUpdate: _verticalUpdate,
      onVerticalDragEnd: _verticalEnd,
      onHorizontalDragEnd: settings.gesturesEnabled
          ? (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity.abs() > 300) _seek(velocity < 0 ? settings.skipSeconds : -settings.skipSeconds);
            }
          : null,
      child: Center(
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: c,
          builder: (_, value, __) {
            if (!value.isInitialized) return const _VideoLoadingShimmer();
            final fit = switch (settings.fitMode) {
              VideoFitMode.cover => BoxFit.cover,
              VideoFitMode.contain => BoxFit.contain,
              VideoFitMode.fill => BoxFit.fill,
            };
            return SizedBox.expand(
              child: FittedBox(
                fit: fit,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(width: value.size.width, height: value.size.height, child: VideoPlayer(c)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _controls() {
    return Stack(
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: IgnorePointer(child: _TopGradient())),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 4,
          right: 4,
          child: Row(
            children: [
              IconButton(onPressed: _pip, tooltip: 'صورة داخل صورة', icon: const Icon(Icons.picture_in_picture_alt_rounded, color: Colors.white)),
              IconButton(onPressed: _fullscreenToggle, tooltip: 'ملء الشاشة', icon: Icon(_fullscreen ? Icons.fullscreen_exit : Icons.fullscreen, color: Colors.white)),
              IconButton(onPressed: _lock, tooltip: 'قفل', icon: const Icon(Icons.lock_open_rounded, color: Colors.white)),
            ],
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          left: 8,
          child: Row(
            children: [
              _SmallAction(icon: Icons.timer, label: _sleepMinutes == null ? 'مؤقت' : '${_sleepMinutes}د', onTap: _sleepMenu),
              const SizedBox(width: 6),
              _SmallAction(icon: Icons.repeat, label: _b == null ? 'A-B' : 'A-B ✓', onTap: _ab),
            ],
          ),
        ),
        Positioned(left: 12, right: 78, bottom: 92, child: IgnorePointer(child: VideoInfo(video: widget.video))),
        Positioned(right: 10, bottom: 92, child: VideoActions(video: widget.video)),
        if (_showControls)
          Positioned(
            left: 12,
            right: 12,
            bottom: MediaQuery.paddingOf(context).bottom + 12,
            child: ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _controller!,
              builder: (_, value, __) {
                return Row(
                  children: [
                    IconButton(icon: Icon(value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white), onPressed: _togglePlay),
                    IconButton(icon: const Icon(Icons.replay_10_rounded, color: Colors.white), onPressed: () => _seek(-settings.skipSeconds)),
                    Expanded(child: VideoProgressIndicator(_controller!, allowScrubbing: true, padding: const EdgeInsets.symmetric(horizontal: 4), colors: const VideoProgressColors(playedColor: AppColors.primary, bufferedColor: Colors.white38, backgroundColor: Colors.white24))),
                    IconButton(icon: const Icon(Icons.forward_10_rounded, color: Colors.white), onPressed: () => _seek(settings.skipSeconds)),
                    IconButton(icon: Icon(value.volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: Colors.white), onPressed: () => _controller?.setVolume(value.volume == 0 ? 1 : 0)),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SmallAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SmallAction({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 4), Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))]),
          ),
        ),
      );
}

class _TopGradient extends StatelessWidget {
  const _TopGradient();
  @override
  Widget build(BuildContext context) => Container(
        height: 140,
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black54, Colors.transparent])),
      );
}

class _VideoLoadingShimmer extends StatelessWidget {
  const _VideoLoadingShimmer();
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: const Color(0xFF101817),
        highlightColor: const Color(0xFF2B3836),
        child: const ColoredBox(color: Color(0xFF171F1E)),
      );
}
