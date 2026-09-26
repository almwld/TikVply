import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

class DeviceMediaService {
  bool _permissionDenied = false;

  bool get permissionDenied => _permissionDenied;

  Future<List<String>> scanAllVideos() async {
    _permissionDenied = false;
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth && !permission.hasAccess) {
      _permissionDenied = true;
      return const <String>[];
    }

    // Read every video album instead of relying on the single virtual
    // "All" album. Removable SD-card media can be exposed through separate
    // MediaStore volume roots on Android.
    final albums = await PhotoManager.getAssetPathList(
      onlyAll: false,
      type: RequestType.video,
    );
    if (albums.isEmpty) return const <String>[];

    final all = <String>[];
    const pageSize = 120;

    for (final album in albums) {
      var page = 0;
      while (true) {
        final assets = await album.getAssetListPaged(
          page: page,
          size: pageSize,
        );
        if (assets.isEmpty) break;

        for (final asset in assets) {
          // Prefer the original file so removable-storage videos retain
          // their native format and remain playable by video_player.
          final file = await asset.originFile ?? await asset.file;
          if (file != null && await file.exists()) {
            all.add(file.path);
          }
        }

        if (assets.length < pageSize) break;
        page++;
      }
    }

    return all.toSet().toList(growable: false);
  }

  Future<void> warmVideoFile(String path) async {
    try {
      await File(path).stat();
    } catch (_) {}
  }
}
