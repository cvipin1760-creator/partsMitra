import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import '../services/settings_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get themeMode => _mode;
  Color _seed = const Color(0xFF2E7D32);
  Color get seedColor => _seed;
  double _textScale = 1.0;
  double get textScale => _textScale;
  double _animationSpeed = 1.0;
  double get animationSpeed => _animationSpeed;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final m = await SettingsService.getThemeMode();
    _mode = _strToMode(m);
    final seed = await SettingsService.getThemeSeedColor();
    if (seed != null) _seed = Color(seed);
    _textScale = await SettingsService.getTextScale();
    _animationSpeed = await SettingsService.getAnimationSpeed();
    timeDilation = _animationSpeed;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    await SettingsService.setThemeMode(_mode.name);
  }

  Future<void> setSeedColor(Color color) async {
    _seed = color;
    notifyListeners();
    await SettingsService.setThemeSeedColor(color.value);
  }

  Future<void> setTextScale(double v) async {
    _textScale = v;
    notifyListeners();
    await SettingsService.setTextScale(v);
  }

  Future<void> setAnimationSpeed(double v) async {
    _animationSpeed = v;
    timeDilation = v;
    notifyListeners();
    await SettingsService.setAnimationSpeed(v);
  }

  ThemeMode _strToMode(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
