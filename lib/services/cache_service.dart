import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Lightweight offline cache: last-known transactions, plans, and balance are
/// stored so the app shows something useful with no connection, instead of a
/// blank screen. This is a cache, not a source of truth — every screen still
/// tries the network first and only falls back to this when that fails.
class CacheService {
  CacheService._();
  static final instance = CacheService._();

  static const _boxName = 'kebaba_cache';
  Box? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  Future<void> putJson(String key, dynamic value) async {
    await _box?.put(key, jsonEncode(value));
  }

  T? getJson<T>(String key, T Function(dynamic decoded) parse) {
    final raw = _box?.get(key);
    if (raw == null) return null;
    try {
      return parse(jsonDecode(raw as String));
    } catch (_) {
      return null;
    }
  }

  DateTime? lastUpdated(String key) {
    final raw = _box?.get('${key}_updated_at');
    return raw != null ? DateTime.tryParse(raw as String) : null;
  }

  Future<void> markUpdated(String key) async {
    await _box?.put('${key}_updated_at', DateTime.now().toIso8601String());
  }
}
