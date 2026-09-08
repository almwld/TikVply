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

  double _playbackSpeed = 1.0;
  VideoFitMode _fitMode = VideoFitMode.cover;
  bool _muted = false;
  bool _autoplay = true;
  bool _loop = true;
  bool _gesturesEnabled = true;

  double get playbackSpeed => _playbackSpeed;
  VideoFitMode get fitMode => _fitMode;
  bool get muted => _muted;
  bool get autoplay => _autoplay;
  bool get loop => _loop;
  bool get gesturesEnabled => _gesturesEnabled;

  VideoSettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _playbackSpeed = prefs.getDouble(_speedKey) ?? 1.0;
    final fit = prefs.getString(_fitKey) ?? VideoFitMode.cover.name;
    _fitMode = VideoFitMode.values.firstWhere(
      (value) => value.name == fit,
      orElse: () => VideoFitMode.cover,
    );
    _muted = prefs.getBool(_mutedKey) ?? false;
    _autoplay = prefs.getBool(_autoplayKey) ?? true;
    _loop = prefs.getBool(_loopKey) ?? true;
    _gesturesEnabled = prefs.getBool(_gesturesKey) ?? true;
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double value) async {
    _playbackSpeed = value.clamp(0.25, 2.0);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_speedKey, _playbackSpeed);
  }

  Future<void> setFitMode(VideoFitMode value) async {
    _fitMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fitKey, value.name);
  }

  Future<void> setMuted(bool value) async {
    _muted = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mutedKey, value);
  }

  Future<void> setAutoplay(bool value) async {
    _autoplay = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoplayKey, value);
  }

  Future<void> setLoop(bool value) async {
    _loop = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loopKey, value);
  }

  Future<void> setGesturesEnabled(bool value) async {
    _gesturesEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_gesturesKey, value);
  }

  Future<void> reset() async {
    _playbackSpeed = 1.0;
    _fitMode = VideoFitMode.cover;
    _muted = false;
    _autoplay = true;
    _loop = true;
    _gesturesEnabled = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_speedKey);
    await prefs.remove(_fitKey);
    await prefs.remove(_mutedKey);
    await prefs.remove(_autoplayKey);
    await prefs.remove(_loopKey);
    await prefs.remove(_gesturesKey);
  }
}
