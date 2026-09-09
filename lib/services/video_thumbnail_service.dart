import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Generates and caches real preview frames for local videos.
class VideoThumbnailService {
  VideoThumbnailService._();

  static final VideoThumbnailService instance = VideoThumbnailService._();

  Directory? _cacheDirectory;
  final Map<String, Future<String?>> _pending = <String, Future<String?>>{};

  Future<Directory> _directory() async {
    final existing = _cacheDirectory;
    if (existing != null) return existing;
    final temp = await getTemporaryDirectory();
    final directory = Directory('${temp.path}/tikvply_thumbnails');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    _cacheDirectory = directory;
    return directory;
  }

  Future<String?> getThumbnailPath(String videoPath) {
    final pending = _pending[videoPath];
    if (pending != null) return pending;

    final future = _generate(videoPath);
    _pending[videoPath] = future;
    future.whenComplete(() => _pending.remove(videoPath));
    return future;
  }

  Future<String?> _generate(String videoPath) async {
    try {
      final video = File(videoPath);
      if (!await video.exists()) return null;

      final directory = await _directory();
      final key = videoPath.hashCode.toRadixString(16);
      final thumbnail = File('${directory.path}/$key.jpg');

      if (await thumbnail.exists() && await thumbnail.length() > 0) {
        return thumbnail.path;
      }

      final generated = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: directory.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 640,
        quality: 78,
        timeMs: 700,
      );

      if (generated == null) return null;
      final generatedFile = File(generated);
      if (!await generatedFile.exists()) return null;

      if (generatedFile.path != thumbnail.path) {
        if (await thumbnail.exists()) await thumbnail.delete();
        await generatedFile.rename(thumbnail.path);
      }
      return thumbnail.path;
    } catch (_) {
      return null;
    }
  }
}
