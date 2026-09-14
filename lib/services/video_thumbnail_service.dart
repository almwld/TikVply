import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Generates and caches real preview frames for local videos without
/// starting many native thumbnail decoders at once while scrolling.
class VideoThumbnailService {
  VideoThumbnailService._();

  static final VideoThumbnailService instance = VideoThumbnailService._();

  Directory? _cacheDirectory;
  final Map<String, Future<String?>> _pending = <String, Future<String?>>{};
  final List<_ThumbnailJob> _queue = <_ThumbnailJob>[];
  int _active = 0;
  static const int _maxActive = 1;

  Future<Directory> _directory() async {
    final existing = _cacheDirectory;
    if (existing != null) return existing;
    final temp = await getTemporaryDirectory();
    final directory = Directory('${temp.path}/tikvply_thumbnails');
    if (!await directory.exists()) await directory.create(recursive: true);
    _cacheDirectory = directory;
    return directory;
  }

  Future<String?> getThumbnailPath(String videoPath) {
    final pending = _pending[videoPath];
    if (pending != null) return pending;

    final completer = Completer<String?>();
    _pending[videoPath] = completer.future;
    _queue.add(_ThumbnailJob(videoPath, completer));
    _pump();
    return completer.future;
  }

  void _pump() {
    while (_active < _maxActive && _queue.isNotEmpty) {
      final job = _queue.removeAt(0);
      _active++;
      _generate(job.path).then(job.completer.complete).catchError((_) => job.completer.complete(null)).whenComplete(() {
        _active--;
        _pending.remove(job.path);
        _pump();
      });
    }
  }

  Future<String?> _generate(String videoPath) async {
    try {
      final video = File(videoPath);
      if (!await video.exists()) return null;

      final directory = await _directory();
      final key = videoPath.hashCode.toRadixString(16);
      final thumbnail = File('${directory.path}/$key.jpg');
      if (await thumbnail.exists() && await thumbnail.length() > 0) return thumbnail.path;

      final generated = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: directory.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 360,
        quality: 62,
        timeMs: 700,
      ).timeout(const Duration(seconds: 8), onTimeout: () => null);

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

class _ThumbnailJob {
  final String path;
  final Completer<String?> completer;
  const _ThumbnailJob(this.path, this.completer);
}
