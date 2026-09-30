import 'package:shared_preferences/shared_preferences.dart';

class VideoPlaybackStateService {
  static const String _prefix = 'playback_position_ms_v1_';
  static const String _watchedPrefix = 'watched_video_v1_';

  // Serialize persistence writes so a delayed save cannot race a clear
  // (for example when playback completes and the page is torn down).
  static Future<void> _writeQueue = Future<void>.value();

  static Future<void> _enqueueWrite(
    Future<void> Function(SharedPreferences prefs) write,
  ) {
    final operation = _writeQueue.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await write(prefs);
    });
    _writeQueue = operation.catchError((_) {});
    return operation;
  }

  Future<Duration?> loadPosition(String videoId) async {
    await _writeQueue;
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt('$_prefix$videoId');
    if (value == null || value <= 0) return null;
    return Duration(milliseconds: value);
  }

  Future<void> savePosition(String videoId, Duration position) async {
    if (position.inMilliseconds <= 0) return;
    await _enqueueWrite(
      (prefs) => prefs.setInt(
        '$_prefix$videoId',
        position.inMilliseconds,
      ),
    );
  }

  Future<void> clearPosition(String videoId) async {
    await _enqueueWrite(
      (prefs) => prefs.remove('$_prefix$videoId'),
    );
  }

  Future<void> markWatched(String videoId) async {
    await _enqueueWrite(
      (prefs) => prefs.setBool('$_watchedPrefix$videoId', true),
    );
  }

  Future<bool> isWatched(String videoId) async {
    await _writeQueue;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_watchedPrefix$videoId') ?? false;
  }
}
