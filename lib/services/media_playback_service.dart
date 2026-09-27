import 'package:flutter/services.dart';

/// Android media-session/foreground-notification bridge.
/// The actual audio/video remains owned by video_player; this bridge exposes
/// system transport controls and keeps a media foreground service alive.
class MediaPlaybackService {
  static const MethodChannel _channel = MethodChannel('com.tikvply/media');
  static Future<void> Function(String action)? _activeHandler;
  static Object? _activeOwner;
  static bool _handlerInstalled = false;
  static final List<String> _pendingActions = <String>[];

  static void initialize() {
    if (_handlerInstalled) return;
    _handlerInstalled = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'mediaAction') {
        final action = call.arguments?.toString() ?? 'open';
        final handler = _activeHandler;
        if (handler != null) {
          await handler(action);
        } else {
          _pendingActions
            ..clear()
            ..add(action);
        }
      }
    });
  }

  static void setActiveHandler(Future<void> Function(String action)? handler, {Object? owner}) {
    _activeHandler = handler;
    _activeOwner = owner;
    if (handler == null || _pendingActions.isEmpty) return;
    final actions = List<String>.from(_pendingActions);
    _pendingActions.clear();
    for (final action in actions) {
      Future<void>.microtask(() async {
        final active = _activeHandler;
        if (active != null) await active(action);
      });
    }
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

  static void clearActiveHandler(Object owner) {
    if (_activeOwner != owner) return;
    _activeHandler = null;
    _activeOwner = null;
  }

  static Future<void> stop({Object? owner}) async {
    if (owner != null && _activeOwner != owner) return;
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
