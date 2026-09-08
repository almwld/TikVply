import 'package:flutter_test/flutter_test.dart';
import 'package:vid_horus/models/user/user_model.dart';
import 'package:vid_horus/models/video/video_model.dart';

void main() {
  test('formats video counters', () {
    final video = VideoModel(
      id: 'local-1',
      userId: 'local_user',
      user: UserModel(
        id: 'local_user',
        username: 'local_library',
        email: 'local@vidhorus.app',
        createdAt: DateTime(2026),
      ),
      videoUrl: '/tmp/video.mp4',
      likesCount: 1500,
      commentsCount: 1200000,
      sharesCount: 42,
      viewsCount: 2300000,
      savesCount: 12,
      createdAt: DateTime(2026),
    );

    expect(video.formatLikes(), '1.5K');
    expect(video.formatComments(), '1.2M');
    expect(video.formatShares(), '42');
    expect(video.formatViews(), '2.3M');
  });

  test('copyWith preserves local file path', () {
    final video = VideoModel(
      id: 'local-2',
      userId: 'local_user',
      videoUrl: '/videos/sample.mp4',
      quality: 'Local',
      createdAt: DateTime(2026),
    );

    final updated = video.copyWith(isSaved: true, viewsCount: 1);

    expect(updated.videoUrl, video.videoUrl);
    expect(updated.isSaved, isTrue);
    expect(updated.viewsCount, 1);
  });
}
