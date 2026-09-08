import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class LocalVideoService {
  static const _key = 'local_video_paths_v1';

  Future<List<String>> loadPaths() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? const <String>[];
    final existing = saved.where((path) => File(path).existsSync()).toList();
    if (existing.length != saved.length) {
      await prefs.setStringList(_key, existing);
    }
    return existing;
  }

  Future<void> addPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList(_key) ?? <String>[];
    if (!paths.contains(path)) {
      paths.insert(0, path);
      await prefs.setStringList(_key, paths);
    }
  }

  Future<void> removePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList(_key) ?? <String>[];
    paths.remove(path);
    await prefs.setStringList(_key, paths);
  }

  Future<void> replacePaths(List<String> paths) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, paths);
  }
}
