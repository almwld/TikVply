import 'package:flutter/material.dart';
import '../models/video/video_model.dart';
import '../models/video/video_sound.dart';
import '../models/user/user_model.dart';

class VideoProvider extends ChangeNotifier {
  List<VideoModel> _videos = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isPlaying = true;
  bool _isMuted = false;
  double _playbackSpeed = 1.0;
  String _currentQuality = 'auto';
  String? _error;

  List<VideoModel> get videos => _videos;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  bool get isMuted => _isMuted;
  double get playbackSpeed => _playbackSpeed;
  String get currentQuality => _currentQuality;
  String? get error => _error;

  VideoProvider() {
    _loadMockVideos();
  }

  void _loadMockVideos() {
    final mockUser = UserModel(
      id: 'user_001',
      username: 'creator_one',
      email: 'creator1@vidhorus.com',
      fullName: 'Creator One',
      avatarUrl: 'https://picsum.photos/100',
      isVerified: true,
      createdAt: DateTime.now(),
    );

    final mockSound = VideoSound(
      id: 'sound_001',
      title: 'Trending Sound',
      artist: 'Artist Name',
      audioUrl: 'https://example.com/audio.mp3',
      usageCount: 50000,
      duration: 30,
      createdAt: DateTime.now(),
    );

    _videos = List.generate(10, (index) {
      return VideoModel(
        id: 'video_$index',
        userId: 'user_00$index',
        user: mockUser.copyWith(
          id: 'user_00$index',
          username: 'creator_$index',
          fullName: 'Creator $index',
        ),
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        thumbnailUrl: 'https://picsum.photos/400/700?random=$index',
        caption: 'Check out this amazing video! 🔥 #trending #fyp #vidhorus',
        hashtags: ['trending', 'fyp', 'vidhorus'],
        sound: mockSound,
        likesCount: (index + 1) * 1000,
        commentsCount: (index + 1) * 100,
        sharesCount: (index + 1) * 50,
        viewsCount: (index + 1) * 10000,
        duration: '0:${15 + index}',
        createdAt: DateTime.now().subtract(Duration(hours: index)),
      );
    });
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void nextVideo() {
    if (_currentIndex < _videos.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousVideo() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void play() {
    _isPlaying = true;
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    notifyListeners();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  void setMuted(bool value) {
    _isMuted = value;
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    notifyListeners();
  }

  void setQuality(String quality) {
    _currentQuality = quality;
    notifyListeners();
  }

  Future<void> likeVideo(String videoId) async {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      final video = _videos[index];
      _videos[index] = video.copyWith(
        isLiked: !video.isLiked,
        likesCount: video.isLiked ? video.likesCount - 1 : video.likesCount + 1,
      );
      notifyListeners();
    }
  }

  Future<void> saveVideo(String videoId) async {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      final video = _videos[index];
      _videos[index] = video.copyWith(
        isSaved: !video.isSaved,
        savesCount: video.isSaved ? video.savesCount - 1 : video.savesCount + 1,
      );
      notifyListeners();
    }
  }

  Future<void> shareVideo(String videoId) async {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      final video = _videos[index];
      _videos[index] = video.copyWith(
        sharesCount: video.sharesCount + 1,
      );
      notifyListeners();
    }
  }

  Future<void> incrementViews(String videoId) async {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      final video = _videos[index];
      _videos[index] = video.copyWith(
        viewsCount: video.viewsCount + 1,
      );
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
