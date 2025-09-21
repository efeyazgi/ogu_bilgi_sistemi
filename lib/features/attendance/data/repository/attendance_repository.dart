import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ogu_not_sistemi_v2/core/services/ogubs_service.dart';
import '../../data/models/attendance_models.dart';

class AttendanceRepository {
  static const _coursesKey = 'attendance_courses_v1';
  static const _entriesKey = 'attendance_entries_v1';
  static const _settingsKey = 'attendance_settings_v1';

  Future<Map<String, dynamic>> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null) return {'weeks': 14};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> _saveSettings(Map<String, dynamic> m) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(m));
  }

  Future<List<AttendanceCourse>> loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_coursesKey);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).map((e) => AttendanceCourse.fromJson(Map<String, dynamic>.from(e))).toList();
    return list;
  }

  Future<void> saveCourses(List<AttendanceCourse> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_coursesKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  Future<void> updateCourseThreshold(String courseCode, double ratio) async {
    final list = await loadCourses();
    final i = list.indexWhere((c) => c.code == courseCode);
    if (i >= 0) {
      list[i] = list[i].copyWith(thresholdRatio: ratio);
      await saveCourses(list);
    }
  }

  Future<void> applyDefaultThresholdToAll(double ratio) async {
    final list = await loadCourses();
    final updated = [for (final c in list) c.copyWith(thresholdRatio: ratio)];
    await saveCourses(updated);
  }

  Future<List<AttendanceEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_entriesKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => AttendanceEntry.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> saveEntries(List<AttendanceEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_entriesKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  Future<int> weeks() async => (await _loadSettings())['weeks'] as int? ?? 14;
  Future<void> setWeeks(int w) async => _saveSettings({'weeks': w});

  // Build courses from schedule + registered
  Future<List<AttendanceCourse>> buildCoursesFromRemote(OgubsService ogubs) async {
    final schedule = await ogubs.fetchSchedule();
    final regs = await ogubs.fetchRegisteredCourses();

    String normalize(String s) => s
        .toUpperCase()
        .replaceAll('İ', 'I')
        .replaceAll('İ', 'I')
        .replaceAll('Ş', 'S')
        .replaceAll('Ğ', 'G')
        .replaceAll('Ü', 'U')
        .replaceAll('Ö', 'O')
        .replaceAll('Ç', 'C')
        .replaceAll(RegExp(r"\s+"), ' ')
        .trim();

    final byName = <String, List<WeeklySlot>>{};
    for (final s in schedule) {
      final n = normalize(s.name);
      final dow = _dowFromName(s.day);
      final slot = WeeklySlot(dayOfWeek: dow, time: s.time, classroom: s.classroom);
      (byName[n] ??= []).add(slot);
    }

    final list = <AttendanceCourse>[];
    for (final r in regs) {
      final n = normalize(r.name);
      final slots = byName[n] ?? [];
      if (slots.isEmpty) continue; // sadece programda görünenler
      list.add(AttendanceCourse(code: r.code, name: r.name, thresholdRatio: 0.30, weeklySlots: slots));
    }
    await saveCourses(list);
    return list;
  }

  Future<void> toggleEntry(String courseCode, String date, String time) async {
    final entries = await loadEntries();
    final idx = entries.indexWhere((e) => e.courseCode == courseCode && e.date == date && e.time == time);
    if (idx >= 0) {
      entries.removeAt(idx);
    } else {
      entries.add(AttendanceEntry(courseCode: courseCode, date: date, time: time));
    }
    await saveEntries(entries);
  }

  Future<List<AttendanceEntry>> entriesFor(String courseCode) async {
    final entries = await loadEntries();
    return entries.where((e) => e.courseCode == courseCode).toList();
  }

  int _dowFromName(String name) {
    switch (name) {
      case 'Pazartesi': return 1;
      case 'Salı': return 2;
      case 'Çarşamba': return 3;
      case 'Perşembe': return 4;
      case 'Cuma': return 5;
      case 'Cumartesi': return 6;
      case 'Pazar': return 7;
      default: return 1;
    }
  }
}