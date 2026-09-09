import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

class DeviceMediaService {
  Future<List<String>> scanAllVideos() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth && !permission.hasAccess) {
      return const <String>[];
    }

    final albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.video,
    );
    if (albums.isEmpty) return const <String>[];

    final all = <String>[];
    const pageSize = 120;
    var page = 0;

    while (true) {
      final assets = await albums.first.getAssetListPaged(
        page: page,
        size: pageSize,
      );
      if (assets.isEmpty) break;

      for (final asset in assets) {
        final file = await asset.file;
        if (file != null && await file.exists()) {
          all.add(file.path);
        }
      }
      if (assets.length < pageSize) break;
      page++;
    }

    return all.toSet().toList(growable: false);
  }

  Future<void> warmVideoFile(String path) async {
    // Touching the file keeps this operation asynchronous and prepares the
    // path for the player without copying or importing the original media.
    try {
      await File(path).stat();
    } catch (_) {}
  }
}
