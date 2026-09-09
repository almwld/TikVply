import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum VideoFitMode { cover, contain, fill }

class VideoSettingsProvider extends ChangeNotifier {
  static const _speedKey = 'video_speed';
  static const _fitKey = 'video_fit';
  static const _mutedKey = 'video_muted';
  static const _autoplayKey = 'video_autoplay';
  static const _loopKey = 'video_loop';
  static const _gesturesKey = 'video_gestures';
  static const _notificationsKey = 'video_notifications';
  static const _wakelockKey = 'video_wakelock';

  double _playbackSpeed = 1.0;
  VideoFitMode _fitMode = VideoFitMode.cover;
  bool _muted = false;
  bool _autoplay = true;
  bool _loop = true;
  bool _gesturesEnabled = true;
  bool _mediaNotifications = true;
  bool _keepScreenAwake = true;

  double get playbackSpeed => _playbackSpeed;
  VideoFitMode get fitMode => _fitMode;
  bool get muted => _muted;
  bool get autoplay => _autoplay;
  bool get loop => _loop;
  bool get gesturesEnabled => _gesturesEnabled;
  bool get mediaNotifications => _mediaNotifications;
  bool get keepScreenAwake => _keepScreenAwake;

  VideoSettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _playbackSpeed = prefs.getDouble(_speedKey) ?? 1.0;
    final fit = prefs.getString(_fitKey) ?? VideoFitMode.cover.name;
    _fitMode = VideoFitMode.values.firstWhere((value) => value.name == fit, orElse: () => VideoFitMode.cover);
    _muted = prefs.getBool(_mutedKey) ?? false;
    _autoplay = prefs.getBool(_autoplayKey) ?? true;
    _loop = prefs.getBool(_loopKey) ?? true;
    _gesturesEnabled = prefs.getBool(_gesturesKey) ?? true;
    _mediaNotifications = prefs.getBool(_notificationsKey) ?? true;
    _keepScreenAwake = prefs.getBool(_wakelockKey) ?? true;
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double value) async => _saveDouble(_speedKey, _playbackSpeed = value.clamp(0.25, 3.0));
  Future<void> setFitMode(VideoFitMode value) async => _saveString(_fitKey, _fitMode = value);
  Future<void> setMuted(bool value) async => _saveBool(_mutedKey, _muted = value);
  Future<void> setAutoplay(bool value) async => _saveBool(_autoplayKey, _autoplay = value);
  Future<void> setLoop(bool value) async => _saveBool(_loopKey, _loop = value);
  Future<void> setGesturesEnabled(bool value) async => _saveBool(_gesturesKey, _gesturesEnabled = value);
  Future<void> setMediaNotifications(bool value) async => _saveBool(_notificationsKey, _mediaNotifications = value);
  Future<void> setKeepScreenAwake(bool value) async => _saveBool(_wakelockKey, _keepScreenAwake = value);

  Future<void> _saveBool(String key, bool value) async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveDouble(String key, double value) async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  Future<void> _saveString(String key, VideoFitMode value) async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value.name);
  }

  Future<void> reset() async {
    _playbackSpeed = 1.0;
    _fitMode = VideoFitMode.cover;
    _muted = false;
    _autoplay = true;
    _loop = true;
    _gesturesEnabled = true;
    _mediaNotifications = true;
    _keepScreenAwake = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    for (final key in [_speedKey, _fitKey, _mutedKey, _autoplayKey, _loopKey, _gesturesKey, _notificationsKey, _wakelockKey]) {
      await prefs.remove(key);
    }
  }
}
