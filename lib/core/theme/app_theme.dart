import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();
  static const Color _seed = Color(0xFF4D6BFE);
  static const Color _lightBg = Color(0xFFF7F8FA);
  static const Color _darkBg = Color(0xFF0E1116);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: _seed);
    return _base(scheme, background: _lightBg);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark);
    return _base(scheme, background: _darkBg);
  }

  static ThemeData _base(ColorScheme scheme, {required Color background}) {
    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(backgroundColor: background, surfaceTintColor: Colors.transparent, elevation: 0, centerTitle: false),
      navigationBarTheme: NavigationBarThemeData(backgroundColor: scheme.surface, indicatorColor: scheme.primary.withValues(alpha: 0.18), elevation: 1),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  static BoxDecoration cardDecoration(BuildContext context, {double radius = 16, Color? borderColor}) {
    final scheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? scheme.outlineVariant),
    );
  }
}
