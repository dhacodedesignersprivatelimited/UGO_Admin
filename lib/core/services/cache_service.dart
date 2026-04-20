import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  CacheService._();

  static const String _dataPrefix = 'cache_data_v1_';
  static const String _timePrefix = 'cache_time_v1_';

  static Future<void> saveData(
    String key,
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_dataPrefix$key', jsonEncode(data));
    await prefs.setString(
      '$_timePrefix$key',
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  static Future<Map<String, dynamic>?> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_dataPrefix$key');
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<DateTime?> getLastUpdated(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_timePrefix$key');
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw).toLocal();
    } catch (_) {
      return null;
    }
  }

  static Future<Duration?> getCacheAge(String key) async {
    final ts = await getLastUpdated(key);
    if (ts == null) return null;
    return DateTime.now().difference(ts);
  }

  static Future<void> clearData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_dataPrefix$key');
    await prefs.remove('$_timePrefix$key');
  }
}
