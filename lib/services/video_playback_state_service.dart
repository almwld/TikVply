import 'package:shared_preferences/shared_preferences.dart';

class VideoPlaybackStateService {
  static const String _prefix = 'playback_position_ms_v1_';

  Future<Duration?> loadPosition(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt('$_prefix$videoId');
    if (value == null || value <= 0) return null;
    return Duration(milliseconds: value);
  }

  Future<void> savePosition(String videoId, Duration position) async {
    if (position.inMilliseconds <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefix$videoId', position.inMilliseconds);
  }

  Future<void> clearPosition(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$videoId');
  }
}
