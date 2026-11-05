import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/l10n/app_strings.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _keyLang = 'settings_language';
  static const String _keyTheme = 'settings_theme_mode';
  static const String _keyWeight = 'settings_weight_kg';
  static const String _keyHeight = 'settings_height_cm';
  static const String _keyGoal = 'settings_daily_goal';

  AppLanguage _language = AppLanguage.en;
  ThemeMode _themeMode = ThemeMode.system;
  double _weightKg = 70;
  double _heightCm = 170;
  int _dailyGoal = 6000;

  AppLanguage get language => _language;
  ThemeMode get themeMode => _themeMode;
  double get weightKg => _weightKg;
  double get heightCm => _heightCm;
  int get dailyGoal => _dailyGoal;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _language = AppLanguage.fromCode(prefs.getString(_keyLang));
    _themeMode = _themeModeFromName(prefs.getString(_keyTheme));
    _weightKg = prefs.getDouble(_keyWeight) ?? 70;
    _heightCm = prefs.getDouble(_keyHeight) ?? 170;
    _dailyGoal = prefs.getInt(_keyGoal) ?? 6000;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;
    _language = language; notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLang, language.code);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode; notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, mode.name);
  }

  Future<void> updateProfile({double? weightKg, double? heightCm, int? dailyGoal}) async {
    if (weightKg != null) _weightKg = weightKg.clamp(20.0, 300.0).toDouble();
    if (heightCm != null) _heightCm = heightCm.clamp(80.0, 250.0).toDouble();
    if (dailyGoal != null) _dailyGoal = dailyGoal.clamp(500, 100000).toInt();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyWeight, _weightKg);
    await prefs.setDouble(_keyHeight, _heightCm);
    await prefs.setInt(_keyGoal, _dailyGoal);
  }

  static ThemeMode _themeModeFromName(String? name) {
    switch (name) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }
}
