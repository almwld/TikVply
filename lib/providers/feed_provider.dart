import 'package:flutter/material.dart';
import '../models/video/video_model.dart';
import '../models/user/user_model.dart';
import '../services/local_video_service.dart';
import '../services/device_media_service.dart';

class VideoProvider extends ChangeNotifier {
  final LocalVideoService _localVideoService = LocalVideoService();
  final DeviceMediaService _deviceMediaService = DeviceMediaService();
  List<VideoModel> _videos = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;

  List<VideoModel> get videos => List.unmodifiable(_videos);
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  bool get hasVideos => _videos.isNotEmpty;

  VideoProvider() {
    loadLocalVideos();
  }

  Future<void> loadLocalVideos() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Restore the last known list immediately, then scan the phone library
      // asynchronously so videos can appear without a picker dialog.
      final cached = await _localVideoService.loadPaths();
      _setVideos(cached);
      notifyListeners();
      await refreshDeviceVideos(notify: false);
    } catch (_) {
      _error = 'تعذر قراءة مكتبة الفيديو في الهاتف';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDeviceVideos({bool notify = true}) async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    _error = null;
    if (notify) notifyListeners();
    try {
      final paths = await _deviceMediaService.scanAllVideos();
      if (paths.isNotEmpty) {
        await _localVideoService.replacePaths(paths);
        _setVideos(paths);
      } else if (_videos.isEmpty) {
        _setVideos(const <String>[]);
      }
    } catch (_) {
      _error = 'تعذر تحديث مكتبة الفيديو';
    } finally {
      _isRefreshing = false;
      if (notify) notifyListeners();
    }
  }

  // Kept for compatibility with existing screens. The app no longer opens
  // a file picker; it always scans the whole accessible phone video library.
  Future<void> importVideos() => refreshDeviceVideos();

  void _setVideos(List<String> paths) {
    final user = _localUser();
    _videos = paths.asMap().entries.map((entry) {
      final path = entry.value;
      return VideoModel(
        id: 'local_${path.hashCode}',
        userId: 'local_user',
        user: user,
        videoUrl: path,
        caption: path.split(RegExp(r'[/\\]')).last,
        duration: '—',
        quality: 'محلي',
        aspectRatio: 9 / 16,
        createdAt: DateTime.now().subtract(Duration(minutes: entry.key)),
      );
    }).toList();
    if (_videos.isEmpty) {
      _currentIndex = 0;
    } else if (_currentIndex >= _videos.length) {
      _currentIndex = _videos.length - 1;
    }
  }

  Future<void> removeVideo(String videoId) async {
    final index = _videos.indexWhere((video) => video.id == videoId);
    if (index == -1) return;
    await _localVideoService.removePath(_videos[index].videoUrl);
    _videos.removeAt(index);
    if (_currentIndex >= _videos.length && _videos.isNotEmpty) _currentIndex = _videos.length - 1;
    if (_videos.isEmpty) _currentIndex = 0;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    if (index < 0 || index >= _videos.length) return;
    _currentIndex = index;
    notifyListeners();
  }

  void nextVideo() {
    if (_currentIndex < _videos.length - 1) setCurrentIndex(_currentIndex + 1);
  }

  void previousVideo() {
    if (_currentIndex > 0) setCurrentIndex(_currentIndex - 1);
  }

  Future<void> likeVideo(String videoId) async => _updateVideo(videoId, (v) => v.copyWith(
        isLiked: !v.isLiked,
        likesCount: v.isLiked ? (v.likesCount - 1).clamp(0, 1 << 30) : v.likesCount + 1,
      ));

  Future<void> saveVideo(String videoId) async => _updateVideo(videoId, (v) => v.copyWith(
        isSaved: !v.isSaved,
        savesCount: v.isSaved ? (v.savesCount - 1).clamp(0, 1 << 30) : v.savesCount + 1,
      ));

  Future<void> shareVideo(String videoId) async => _updateVideo(videoId, (v) => v.copyWith(sharesCount: v.sharesCount + 1));

  Future<void> incrementViews(String videoId) async => _updateVideo(videoId, (v) => v.copyWith(viewsCount: v.viewsCount + 1));

  Future<void> _updateVideo(String id, VideoModel Function(VideoModel) update) async {
    final index = _videos.indexWhere((video) => video.id == id);
    if (index == -1) return;
    _videos[index] = update(_videos[index]);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  UserModel _localUser() => UserModel(
        id: 'local_user',
        username: 'مكتبة الهاتف',
        email: 'local@tikvply.app',
        fullName: 'فيديوهاتي',
        avatarUrl: null,
        isVerified: false,
        createdAt: DateTime.now(),
      );
}
