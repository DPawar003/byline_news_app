import 'package:flutter/material.dart';
import '../services/hive_service.dart';

class ThemeViewModel extends ChangeNotifier {
  final HiveService _hiveService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeViewModel({required HiveService hiveService}) : _hiveService = hiveService {
    _loadThemePref();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }

  void _loadThemePref() {
    final prefStr = _hiveService.getThemePref();
    switch (prefStr) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (isDarkMode) {
      _themeMode = ThemeMode.light;
      await _hiveService.saveThemePref('light');
    } else {
      _themeMode = ThemeMode.dark;
      await _hiveService.saveThemePref('dark');
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final modeStr = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await _hiveService.saveThemePref(modeStr);
    notifyListeners();
  }
}
