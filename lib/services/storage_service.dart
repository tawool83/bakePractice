import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/practice.dart';

/// 앱 상태를 기기에 저장 (Android: SharedPreferences, Web: localStorage)
class StorageService {
  /// 저장 형식을 바꾸면 버전을 올릴 것
  static const String key = 'bake-practice-v1';

  Future<AppData> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return AppData();
      return AppData.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (e) {
      debugPrint('저장된 데이터를 읽지 못함: $e');
      return AppData();
    }
  }

  Future<void> save(AppData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(data.toJson()));
    } catch (e) {
      debugPrint('저장 실패: $e');
    }
  }
}
