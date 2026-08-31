import 'package:flutter/material.dart';

/// Warm Utilitarian tokens (brewdesk#98 / flutter#6): green/sand/sage
/// system, value-for-value parity with the native
/// `BrewDeskKit/BrewDeskStyle.swift` (`BrewDeskPalette`). Fill/pin tokens
/// stay single static values — they always sit behind fixed white text
/// (badges, map pins) so they must not shift between light and dark.
abstract final class AppColors {
  /// Primary green (`roast`) — CTAs, "great" tier, selected chips/pins.
  static const green = Color(0xFF2D5A4C);

  /// Primary ramp step 3 — the branded loading backdrop.
  static const deepGreen = Color(0xFF1F3E34);

  /// Tertiary sage as a FILL (`moss`) — "good" tier, icon glyphs.
  static const moss = Color(0xFF769382);

  /// Tertiary sage, pastel decorative step (ramp 6) — indicator tints,
  /// empty-state icons. What the old `sage` value approximated.
  static const sage = Color(0xFFA2B4A9);

  /// Secondary sand (`oat`) — banner/chip fill.
  static const sand = Color(0xFFE8E2D2);

  /// Sand deepened for white-text legibility (secondary ramp 2) —
  /// "mixed" tier fill. Native token name: `sand`.
  static const sandDeep = Color(0xFF625532);

  /// Destructive, deeper (`berry`, destructive ramp 4) — "weak" tier fill.
  static const berry = Color(0xFF5F2B1F);

  /// Neutral near-white (`foam`) — light page background.
  static const cream = Color(0xFFFAF9F6);

  /// Ink (`espresso`) — hairlines, dark-on-light text, inverted fills.
  static const ink = Color(0xFF2B2B2B);

  /// Dark-mode page: deep green-black (`page` dark).
  static const charcoal = Color(0xFF15201C);

  /// Dark-mode card surface (`surface` dark).
  static const nightSurface = Color(0xFF1E2A25);
}

/// Type roles (native `BrewDeskFont` parity): headline **Hanken Grotesk**,
/// body **Manrope**, labels/eyebrows/numbers **JetBrains Mono** — all OFL,
/// bundled as variable TTFs under `fonts/`.
abstract final class AppFonts {
  static const headline = 'HankenGrotesk';
  static const body = 'Manrope';
  static const label = 'JetBrainsMono';

  /// The bundled faces are VARIABLE fonts: `fontWeight` alone selects a
  /// face at matching time, but the rendered instance comes from the
  /// `wght` axis — set both so weight survives whichever path the engine
  /// takes. Use with `copyWith(fontWeight:, fontVariations:)`.
  static List<FontVariation> wght(double value) => [
    FontVariation('wght', value),
  ];
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
      textTheme: _textTheme(base.textTheme),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.sage.withValues(alpha: 0.35),
        labelTextStyle: WidgetStatePropertyAll(
          _label(base.textTheme.labelMedium, 700),
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

  /// Native `BrewDeskFont` role mapping: display/headline/title → Hanken
  /// Grotesk (bold), body → Manrope, label → JetBrains Mono (semibold).
  /// Weights are baked into each style as `wght` variations so variable
  /// faces render the intended instance even where call sites only inherit.
  static TextTheme _textTheme(TextTheme base) {
    TextStyle? head(TextStyle? style, double weight) => style?.copyWith(
      fontFamily: AppFonts.headline,
      fontWeight: _closest(weight),
      fontVariations: AppFonts.wght(weight),
    );
    TextStyle? body(TextStyle? style) =>
        style?.copyWith(fontFamily: AppFonts.body);
    return TextTheme(
      displayLarge: head(base.displayLarge, 700),
      displayMedium: head(base.displayMedium, 700),
      displaySmall: head(base.displaySmall, 700),
      headlineLarge: head(base.headlineLarge, 700),
      headlineMedium: head(base.headlineMedium, 700),
      headlineSmall: head(base.headlineSmall, 700),
      titleLarge: head(base.titleLarge, 700),
      titleMedium: head(base.titleMedium, 600),
      titleSmall: head(base.titleSmall, 600),
      bodyLarge: body(base.bodyLarge),
      bodyMedium: body(base.bodyMedium),
      bodySmall: body(base.bodySmall),
      labelLarge: _label(base.labelLarge, 600),
      labelMedium: _label(base.labelMedium, 600),
      labelSmall: _label(base.labelSmall, 600),
    );
  }

  static TextStyle? _label(TextStyle? style, double weight) => style?.copyWith(
    fontFamily: AppFonts.label,
    fontWeight: _closest(weight),
    fontVariations: AppFonts.wght(weight),
  );

  static FontWeight _closest(double weight) =>
      FontWeight.values[(weight / 100).round() - 1];
}
