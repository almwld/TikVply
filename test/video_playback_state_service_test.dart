import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tikvply/services/video_playback_state_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('saves and restores playback position', () async {
    final service = VideoPlaybackStateService();
    const id = 'local_video_1';
    const position = Duration(seconds: 37);

    await service.savePosition(id, position);

    expect(await service.loadPosition(id), position);
  });

  test('ignores zero and negative playback positions', () async {
    final service = VideoPlaybackStateService();
    const id = 'local_video_2';

    await service.savePosition(id, Duration.zero);
    expect(await service.loadPosition(id), isNull);

    await service.savePosition(id, const Duration(milliseconds: -1));
    expect(await service.loadPosition(id), isNull);
  });

  test('clears playback position and tracks watched state', () async {
    final service = VideoPlaybackStateService();
    const id = 'local_video_3';

    await service.savePosition(id, const Duration(seconds: 12));
    await service.markWatched(id);

    expect(await service.loadPosition(id), const Duration(seconds: 12));
    expect(await service.isWatched(id), isTrue);

    await service.clearPosition(id);
    expect(await service.loadPosition(id), isNull);
  });

  test('watched state defaults to false', () async {
    final service = VideoPlaybackStateService();
    expect(await service.isWatched('missing_video'), isFalse);
  });
}
