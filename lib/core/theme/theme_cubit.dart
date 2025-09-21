import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final StorageService storage;
  ThemeCubit({required this.storage}) : super(ThemeMode.system) {
    _init();
  }

  Future<void> _init() async {
    final saved = await storage.loadThemeMode();
    emit(saved);
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    emit(next);
    await storage.saveThemeMode(next);
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await storage.saveThemeMode(mode);
  }
}
