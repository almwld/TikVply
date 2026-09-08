import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_colors.dart';
import '../../models/video/video_model.dart';
import '../../providers/feed_provider.dart';
import '../profile/profile_screen.dart';
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
  bool _isInitialized = false;
  bool _showControls = true;
  bool _showLikeAnimation = false;
  Offset _likeAnimationPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.videoUrl),
    );

    try {
      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.play();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  void _onDoubleTap(TapDownDetails details) {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    if (!widget.video.isLiked) {
      videoProvider.likeVideo(widget.video.id);
    }

    setState(() {
      _showLikeAnimation = true;
      _likeAnimationPosition = details.localPosition;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showLikeAnimation = false;
        });
      }
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_controller != null) {
      final double delta = details.primaryDelta ?? 0;
      final double currentPosition = _controller!.value.position.inSeconds.toDouble();
      final double newPosition = currentPosition + delta * 0.5;

      _controller!.seekTo(Duration(seconds: newPosition.round()));
    }
  }

  void _showUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(userId: widget.video.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
          _togglePlayPause();
        },
        onDoubleTapDown: _onDoubleTap,
        onDoubleTap: () {
          final videoProvider = Provider.of<VideoProvider>(context, listen: false);
          videoProvider.likeVideo(widget.video.id);
        },
        onVerticalDragUpdate: _onVerticalDragUpdate,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Player
            if (_isInitialized && _controller != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              )
            else
              Container(
                color: AppColors.dark,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),

            // Gradient Overlays
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Top gradient for status bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Video Info (Left side)
            if (_isInitialized)
              Positioned(
                left: 12,
                right: 80,
                bottom: 100,
                child: VideoInfo(video: widget.video),
              ),

            // Actions (Right side)
            if (_isInitialized)
              Positioned(
                right: 12,
                bottom: 100,
                child: VideoActions(video: widget.video),
              ),

            // Like Animation
            if (_showLikeAnimation)
              Positioned(
                left: _likeAnimationPosition.dx - 50,
                top: _likeAnimationPosition.dy - 50,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.5, end: 1.2),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: 1.0 - (scale - 0.5) / 0.7,
                        child: const Icon(
                          Icons.favorite,
                          color: AppColors.secondary,
                          size: 100,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Bottom safe area
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).padding.bottom + 60,
                color: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
