import 'package:flutter/services.dart';

/// Android media-session/foreground-notification bridge.
/// The actual audio/video remains owned by video_player; this bridge exposes
/// system transport controls and keeps a media foreground service alive.
class MediaPlaybackService {
  static const MethodChannel _channel = MethodChannel('com.tikvply/media');
  static Future<void> Function(String action)? _activeHandler;
  static bool _handlerInstalled = false;

  static void initialize() {
    if (_handlerInstalled) return;
    _handlerInstalled = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'mediaAction') {
        await _activeHandler?.call(call.arguments?.toString() ?? 'open');
      }
    });
  }

  static void setActiveHandler(Future<void> Function(String action)? handler) {
    _activeHandler = handler;
  }

  static Future<void> requestNotificationPermission() async {
    try { await _channel.invokeMethod('requestNotificationPermission'); } catch (_) {}
  }

  static Future<void> start({
    required String title,
    required bool playing,
  }) async {
    try {
      await requestNotificationPermission();
      await _channel.invokeMethod('startMedia', {
        'title': title,
        'playing': playing,
      });
    } catch (_) {}
  }

  static Future<void> update({required bool playing}) async {
    try {
      await _channel.invokeMethod('updateMedia', {'playing': playing});
    } catch (_) {}
  }

  static Future<void> stop() async {
    try { await _channel.invokeMethod('stopMedia'); } catch (_) {}
  }

  static Future<void> showSmartUnseenNotification(int count) async {
    if (count <= 0) return;
    try {
      await requestNotificationPermission();
      await _channel.invokeMethod('showUnseenVideos', {'count': count});
    } catch (_) {}
  }
}
