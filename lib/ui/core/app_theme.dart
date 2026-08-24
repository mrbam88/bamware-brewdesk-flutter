import 'package:flutter/material.dart';

abstract final class AppColors {
  static const green = Color(0xFF2D5A4C);
  static const deepGreen = Color(0xFF173B32);
  static const sage = Color(0xFFAFC4B8);
  static const sand = Color(0xFFE8DDC8);
  static const cream = Color(0xFFFAF9F6);
  static const ink = Color(0xFF1D211F);
  static const charcoal = Color(0xFF121715);
  static const nightSurface = Color(0xFF1B2421);
  static const scoreGood = Color(0xFF6A8B63);
  static const scoreMixed = Color(0xFFC18D47);
}

abstract final class AppTheme {
  static ThemeData get light => _theme(
    brightness: Brightness.light,
    background: AppColors.cream,
    surface: Colors.white,
    ink: AppColors.ink,
  );

  static ThemeData get dark => _theme(
    brightness: Brightness.dark,
    background: AppColors.charcoal,
    surface: AppColors.nightSurface,
    ink: AppColors.cream,
  );

  static ThemeData _theme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color ink,
  }) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.green,
          brightness: brightness,
          surface: surface,
        ).copyWith(
          primary: brightness == Brightness.light
              ? AppColors.green
              : AppColors.sage,
          onPrimary: brightness == Brightness.light
              ? AppColors.cream
              : AppColors.charcoal,
          secondary: AppColors.sand,
          onSurface: ink,
          surface: surface,
        );
    final base = ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      useMaterial3: true,
    );
    return base.copyWith(
      scaffoldBackgroundColor: background,
      textTheme: base.textTheme.apply(fontFamily: 'sans-serif'),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.sage.withValues(alpha: 0.35),
        labelTextStyle: WidgetStatePropertyAll(
          base.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
