/// Serializes native video-player ownership across every route and entry point.
///
/// A new page cannot initialize its player until the previous owner's stop
/// callback has completed. Releasing an obsolete owner never clears a newer
/// owner's lease.
class VideoPlaybackCoordinator {
  VideoPlaybackCoordinator._();

  static Future<void> _queue = Future<void>.value();
  static Object? _activeOwner;
  static Future<void> Function()? _stopActive;

  static Object? get activeOwner => _activeOwner;

  static Future<void> acquire(
    Object owner,
    Future<void> Function() stopOwner,
  ) {
    final next = _queue.then((_) async {
      if (!identical(_activeOwner, owner)) {
        final stopPrevious = _stopActive;
        _activeOwner = null;
        _stopActive = null;
        if (stopPrevious != null) {
          try {
            await stopPrevious();
          } catch (_) {
            // A broken outgoing player must not permanently block playback.
          }
        }
      }
      _activeOwner = owner;
      _stopActive = stopOwner;
    });
    _queue = next.catchError((_) {});
    return next;
  }

  static Future<void> release(Object owner) {
    final next = _queue.then((_) async {
      if (!identical(_activeOwner, owner)) return;
      final stop = _stopActive;
      try {
        if (stop != null) await stop();
      } finally {
        if (identical(_activeOwner, owner)) {
          _activeOwner = null;
          _stopActive = null;
        }
      }
    });
    _queue = next.catchError((_) {});
    return next;
  }

  static bool owns(Object owner) => identical(_activeOwner, owner);
}
