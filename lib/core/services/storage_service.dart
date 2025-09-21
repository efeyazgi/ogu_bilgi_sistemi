import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class StorageService {
  static const String _studentNumberKey = 'student_number';
  static const String _passwordKey =
      'password'; // Dikkat: Şifreleri düz metin olarak saklamak güvenlik açığıdır.
  // Gerçek bir uygulamada flutter_secure_storage gibi bir paket kullanılmalıdır.

  static const String _courseColorsKey = 'course_colors_v1';
  static const String _themeModeKey = 'theme_mode_v1';
  static const String _gradCreditsKey = 'graduation_credits_v1';

  Future<void> saveCredentials(String studentNumber, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_studentNumberKey, studentNumber);
    await prefs.setString(_passwordKey, password);
    developer.log('Credentials saved.');
  }

  Future<Map<String, String>?> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final studentNumber = prefs.getString(_studentNumberKey);
    final password = prefs.getString(_passwordKey);

    if (studentNumber != null && password != null) {
      developer.log('Credentials loaded: $studentNumber');
      return {'studentNumber': studentNumber, 'password': password};
    }
    developer.log('No credentials found.');
    return null;
  }

  Future<void> deleteCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_studentNumberKey);
    await prefs.remove(_passwordKey);
    developer.log('Credentials deleted.');
  }

  // Ders renkleri (isim -> ARGB int) saklama/okuma
  Future<Map<String, int>> loadCourseColors() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_courseColorsKey);
    if (json == null || json.isEmpty) return {};
    try {
      final map = Map<String, dynamic>.from(await Future.value(_decode(json)));
      return map.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveCourseColor(String normalizedCourseName, int argb) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadCourseColors();
    current[normalizedCourseName] = argb;
    final json = _encode(current);
    await prefs.setString(_courseColorsKey, json);
  }

  Future<void> removeCourseColor(String normalizedCourseName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadCourseColors();
    current.remove(normalizedCourseName);
    final json = _encode(current);
    await prefs.setString(_courseColorsKey, json);
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_themeModeKey);
    switch (v) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> saveGraduationCredits(int credits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_gradCreditsKey, credits);
  }

  Future<int> loadGraduationCredits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_gradCreditsKey) ?? 160;
  }

  // Basit JSON encode/decode (dart:convert yerine min bağımlılık)
  String _encode(Map<String, int> map) {
    final entries = map.entries
        .map((e) => '"${e.key.replaceAll("\"", "\\\"")}":${e.value}')
        .join(',');
    return '{$entries}';
  }

  Map<String, dynamic> _decode(String json) {
    // Çok basit bir parser; üretimde dart:convert kullanılır.
    final result = <String, dynamic>{};
    final trimmed = json.trim();
    if (!trimmed.startsWith('{') || !trimmed.endsWith('}')) return result;
    final body = trimmed.substring(1, trimmed.length - 1).trim();
    if (body.isEmpty) return result;
    final parts = body.split(',');
    for (final p in parts) {
      final idx = p.indexOf(':');
      if (idx <= 0) continue;
      final k = p.substring(0, idx).trim();
      final v = p.substring(idx + 1).trim();
      final key = k.replaceAll('"', '');
      final value = int.tryParse(v) ?? 0;
      result[key] = value;
    }
    return result;
  }
}
