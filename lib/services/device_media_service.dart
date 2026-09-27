import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

class DeviceMediaService {
  bool _permissionDenied = false;
  bool _permissionLimited = false;

  bool get permissionDenied => _permissionDenied;
  bool get permissionLimited => _permissionLimited;

  Future<List<String>> scanAllVideos() async {
    _permissionDenied = false;
    _permissionLimited = false;
    final permission = await PhotoManager.requestPermissionExtend();
    _permissionLimited = permission.isLimited;
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
          // Use the regular MediaStore file first. It is substantially cheaper
          // for large libraries; fall back to the original only when needed
          // for removable-storage providers that do not expose a direct file.
          final file = await asset.file ?? await asset.originFile;
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
