import 'package:flutter_test/flutter_test.dart';
import 'package:tikvply/services/video_playback_coordinator.dart';

void main() {
  group('VideoPlaybackCoordinator', () {
    test('stops the previous owner before granting the next lease', () async {
      final first = Object();
      final second = Object();
      var firstStopped = false;

      await VideoPlaybackCoordinator.acquire(first, () async {
        firstStopped = true;
      });
      await VideoPlaybackCoordinator.acquire(second, () async {
        fail('The second owner should not be stopped');
      });

      expect(firstStopped, isTrue);
      expect(VideoPlaybackCoordinator.owns(first), isFalse);
      expect(VideoPlaybackCoordinator.owns(second), isTrue);
      await VideoPlaybackCoordinator.release(second);
    });

    test('releasing a stale owner cannot clear the current lease', () async {
      final current = Object();
      final stale = Object();

      await VideoPlaybackCoordinator.acquire(current, () async {});
      await VideoPlaybackCoordinator.release(stale);

      expect(VideoPlaybackCoordinator.owns(current), isTrue);
      await VideoPlaybackCoordinator.release(current);
    });

    test('release awaits teardown before clearing ownership', () async {
      final owner = Object();
      var stopped = false;

      await VideoPlaybackCoordinator.acquire(owner, () async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        stopped = true;
      });
      await VideoPlaybackCoordinator.release(owner);

      expect(stopped, isTrue);
      expect(VideoPlaybackCoordinator.owns(owner), isFalse);
    });
  });
}
