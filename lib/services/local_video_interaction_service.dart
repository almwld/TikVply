import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists local video interactions so Like/Save/Follow/View state survives
/// app restarts. This is intentionally local-only until a backend is connected.
class LocalVideoInteractionService {
  static const _stateKey = 'tikvply_video_interactions_v1';

  Future<Map<String, dynamic>> _read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_stateKey);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return <String, dynamic>{};
  }

  Future<void> _write(Map<String, dynamic> state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stateKey, jsonEncode(state));
  }

  Future<Map<String, dynamic>> load(String videoId) async {
    final state = await _read();
    final value = state[videoId];
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  Future<void> update(String videoId, Map<String, dynamic> patch) async {
    final state = await _read();
    final current = state[videoId] is Map
        ? Map<String, dynamic>.from(state[videoId] as Map)
        : <String, dynamic>{};
    current.addAll(patch);
    state[videoId] = current;
    await _write(state);
  }

  Future<void> remove(String videoId) async {
    final state = await _read();
    state.remove(videoId);
    await _write(state);
  }
}
