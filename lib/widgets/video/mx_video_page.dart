import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../models/video/video_model.dart';
import '../../providers/video_settings_provider.dart';

/// Stable local-media player backed directly by libmpv through media_kit.
/// This is intentionally separate from the legacy video_player screen so a
/// broken/unsupported file can never leave the browser's shimmer mounted forever.
class MxVideoPage extends StatefulWidget {
  final VideoModel video;
  final VoidCallback? onCompleted;

  const MxVideoPage({super.key, required this.video, this.onCompleted});

  @override
  State<MxVideoPage> createState() => _MxVideoPageState();
}

class _MxVideoPageState extends State<MxVideoPage> with WidgetsBindingObserver {
  late final Player _player;
  late final VideoController _videoController;
  StreamSubscription<bool>? _completedSubscription;
  StreamSubscription<String>? _errorSubscription;
  Timer? _wakeTimer;
  bool _loading = true;
  bool _failed = false;
  bool _completedSent = false;
  String? _error;

  VideoSettingsProvider get settings => context.read<VideoSettingsProvider>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _player = Player(
      configuration: const PlayerConfiguration(
        muted: false,
      ),
    );
    _videoController = VideoController(
      _player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
        scale: 1.0,
      ),
    );
    _completedSubscription = _player.stream.completed.listen((completed) {
      if (completed && !_completedSent) {
        _completedSent = true;
        widget.onCompleted?.call();
      }
    });
    _errorSubscription = _player.stream.error.listen((message) {
      if (!mounted || message.isEmpty) return;
      debugPrint('TikVply media_kit error: $message');
      setState(() {
        _loading = false;
        _failed = true;
        _error = message;
      });
    });
    _open();
  }

  Future<void> _open() async {
    final path = widget.video.videoUrl;
    try {
      if (!path.startsWith('http://') && !path.startsWith('https://')) {
        final file = File(path);
        if (!await file.exists()) {
          throw StateError('الملف غير موجود');
        }
      }

      await _player.setPlaylistMode(PlaylistMode.none);
      await _player.setRate(settings.playbackSpeed);
      await _player.setVolume(settings.muted ? 0 : 100);
      await _player.setPlaylistMode(settings.loop ? PlaylistMode.single : PlaylistMode.none);

      // open() is deliberately bounded: an unreadable file must not keep the
      // UI on a shimmer forever. libmpv performs the actual codec detection.
      await _player.open(Media(path), play: false).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = false;
      });

      if (settings.autoplay) {
        await _player.play();
        _updateWakeLock(true);
      }
    } catch (error, stack) {
      debugPrint('TikVply media_kit open failed: $error');
      debugPrintStack(stackTrace: stack);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
        _error = 'تعذر تشغيل هذا الملف';
      });
      _completeAfterFailure();
    }
  }

  void _completeAfterFailure() {
    if (_completedSent || widget.onCompleted == null) return;
    _completedSent = true;
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (mounted) widget.onCompleted?.call();
    });
  }

  void _updateWakeLock(bool playing) {
    _wakeTimer?.cancel();
    if (playing && settings.keepScreenAwake) {
      WakelockPlus.enable();
    } else {
      _wakeTimer = Timer(const Duration(milliseconds: 100), WakelockPlus.disable);
    }
  }

  Future<void> _togglePlay() async {
    if (_failed) return;
    await _player.playOrPause();
    _updateWakeLock(_player.state.playing);
  }

  Future<void> _retry() async {
    _completedSent = false;
    setState(() {
      _loading = true;
      _failed = false;
      _error = null;
    });
    await _player.stop();
    await _open();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (!_player.state.playing) return;
      _player.pause();
      _updateWakeLock(false);
    } else if (state == AppLifecycleState.resumed && !_failed && settings.autoplay) {
      _player.play();
      _updateWakeLock(true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _completedSubscription?.cancel();
    _errorSubscription?.cancel();
    _wakeTimer?.cancel();
    WakelockPlus.disable();
    _videoController.player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (!_failed) Video(controller: _videoController, controls: AdaptiveVideoControls),
          if (_loading) const _LoadingOverlay(),
          if (_failed) _FailureOverlay(message: _error, onRetry: _retry),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 6,
            right: 6,
            child: IconButton(
              tooltip: 'إغلاق',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
            ),
          ),
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 10,
            left: 10,
            child: StreamBuilder<bool>(
              stream: _player.stream.playing,
              initialData: false,
              builder: (_, snapshot) => DecoratedBox(
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(28)),
                child: IconButton(
                  tooltip: snapshot.data == true ? 'إيقاف مؤقت' : 'تشغيل',
                  onPressed: _togglePlay,
                  icon: Icon(snapshot.data == true ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
}

class _FailureOverlay extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _FailureOverlay({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.video_file_outlined, color: Colors.white54, size: 58),
                const SizedBox(height: 14),
                const Text('تعذر تشغيل الفيديو', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                if (message != null) ...[
                  const SizedBox(height: 6),
                  Text(message!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('إعادة المحاولة')),
              ],
            ),
          ),
        ),
      );
}
