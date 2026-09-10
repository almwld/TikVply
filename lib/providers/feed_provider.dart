import 'package:flutter/material.dart';
import '../models/video/video_model.dart';
import '../models/user/user_model.dart';
import '../services/local_video_service.dart';
import '../services/device_media_service.dart';
import '../services/local_video_interaction_service.dart';

enum VideoSort { newest, oldest, duration }

class VideoProvider extends ChangeNotifier {
  final LocalVideoService _localVideoService = LocalVideoService();
  final DeviceMediaService _deviceMediaService = DeviceMediaService();
  final LocalVideoInteractionService _interactionService = LocalVideoInteractionService();
  List<VideoModel> _allVideos = [];
  List<VideoModel> _videos = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  String _query = '';
  VideoSort _sort = VideoSort.newest;

  List<VideoModel> get videos => List.unmodifiable(_videos);
  int get totalVideos => _allVideos.length;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  bool get hasVideos => _videos.isNotEmpty;
  String get query => _query;
  VideoSort get sort => _sort;

  VideoProvider() {
    loadLocalVideos();
  }

  Future<void> loadLocalVideos() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final cached = await _localVideoService.loadPaths();
      await _setVideos(cached);
      notifyListeners();
      await refreshDeviceVideos(notify: false);
    } catch (error) {
      _error = 'تعذر قراءة مكتبة الفيديو في الهاتف';
      debugPrint('TikVply video library load failed: $error');
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
      if (_deviceMediaService.permissionDenied) {
        _error = 'يحتاج TikVply إلى إذن الوصول إلى فيديوهات الهاتف';
        return;
      }
      await _localVideoService.replacePaths(paths);
      await _setVideos(paths);
    } catch (error, stackTrace) {
      _error = 'تعذر تحديث مكتبة الفيديو';
      debugPrint('TikVply video library refresh failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isRefreshing = false;
      if (notify) notifyListeners();
    }
  }

  Future<void> importVideos() => refreshDeviceVideos();

  Future<void> _setVideos(List<String> paths) async {
    final user = _localUser();
    final uniquePaths = <String>{...paths}.toList(growable: false);
    final loaded = <VideoModel>[];
    for (final entry in uniquePaths.asMap().entries) {
      final path = entry.value;
      final id = 'local_${path.hashCode}';
      final state = await _interactionService.load(id);
      loaded.add(VideoModel(
        id: id,
        userId: 'local_user',
        user: user,
        videoUrl: path,
        caption: path.split(RegExp(r'[/\\]')).last,
        likesCount: _int(state['likesCount']),
        sharesCount: _int(state['sharesCount']),
        viewsCount: _int(state['viewsCount']),
        savesCount: _int(state['savesCount']),
        isLiked: state['isLiked'] == true,
        isSaved: state['isSaved'] == true,
        isFollowing: state['isFollowing'] == true,
        duration: '—',
        quality: 'محلي',
        aspectRatio: 9 / 16,
        createdAt: DateTime.now().subtract(Duration(minutes: entry.key)),
      ));
    }
    _allVideos = loaded;
    _applyFilterAndSort(notify: false);
    if (_videos.isEmpty) {
      _currentIndex = 0;
    } else if (_currentIndex >= _videos.length) {
      _currentIndex = _videos.length - 1;
    }
  }

  static int _int(dynamic value) => value is num ? value.toInt() : 0;

  Future<void> removeVideo(String videoId) async {
    final index = _allVideos.indexWhere((video) => video.id == videoId);
    if (index == -1) return;
    final path = _allVideos[index].videoUrl;
    await _localVideoService.removePath(path);
    await _interactionService.remove(videoId);
    _allVideos.removeAt(index);
    _applyFilterAndSort(notify: false);
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

  void setSearchQuery(String value) {
    _query = value.trim();
    _applyFilterAndSort();
  }

  void setSort(VideoSort value) {
    _sort = value;
    _applyFilterAndSort();
  }

  void clearSearch() => setSearchQuery('');

  void _applyFilterAndSort({bool notify = true}) {
    final query = _query.toLowerCase();
    final filtered = _allVideos.where((video) {
      if (query.isEmpty) return true;
      final haystack = '${video.caption ?? ''} ${video.user?.username ?? ''} ${video.hashtags.join(' ')}'.toLowerCase();
      return haystack.contains(query);
    }).toList();
    switch (_sort) {
      case VideoSort.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case VideoSort.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case VideoSort.duration:
        filtered.sort((a, b) => a.duration.compareTo(b.duration));
    }
    _videos = filtered;
    if (_videos.isEmpty) _currentIndex = 0;
    if (notify) notifyListeners();
  }

  Future<void> likeVideo(String videoId) async {
    await _updateVideo(videoId, (v) => v.copyWith(
      isLiked: !v.isLiked,
      likesCount: v.isLiked ? (v.likesCount - 1).clamp(0, 1 << 30) : v.likesCount + 1,
    ));
  }

  Future<void> saveVideo(String videoId) async {
    await _updateVideo(videoId, (v) => v.copyWith(
      isSaved: !v.isSaved,
      savesCount: v.isSaved ? (v.savesCount - 1).clamp(0, 1 << 30) : v.savesCount + 1,
    ));
  }

  Future<void> shareVideo(String videoId) async => _updateVideo(videoId, (v) => v.copyWith(sharesCount: v.sharesCount + 1));

  Future<void> incrementViews(String videoId) async => _updateVideo(videoId, (v) => v.copyWith(viewsCount: v.viewsCount + 1));

  Future<void> followUserForVideo(String videoId) async => _updateVideo(videoId, (v) => v.copyWith(isFollowing: !v.isFollowing));

  Future<void> _updateVideo(String id, VideoModel Function(VideoModel) update) async {
    final index = _allVideos.indexWhere((video) => video.id == id);
    if (index == -1) return;
    final updated = update(_allVideos[index]);
    _allVideos[index] = updated;
    _applyFilterAndSort(notify: false);
    await _interactionService.update(id, {
      'likesCount': updated.likesCount,
      'savesCount': updated.savesCount,
      'sharesCount': updated.sharesCount,
      'viewsCount': updated.viewsCount,
      'isLiked': updated.isLiked,
      'isSaved': updated.isSaved,
      'isFollowing': updated.isFollowing,
    });
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
