import 'package:flutter/material.dart';

/// The app's visual identity: deep emerald Material 3 with Tajawal type.
class AppTheme {
  static const seed = Color(0xFF0E7C66);

  /// Warm gold accent used for "leave soon" states and highlights.
  static const gold = Color(0xFFE8B84B);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme =
        ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    final base = ThemeData(
      colorScheme: scheme,
      fontFamily: 'Tajawal',
    );
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          textStyle: base.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700, fontFamily: 'Tajawal'),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.4),
      ),
    );
  }

  /// Gradient for the hero countdown card.
  static LinearGradient heroGradient(ColorScheme scheme) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: scheme.brightness == Brightness.light
            ? [const Color(0xFF0E7C66), const Color(0xFF0A5D4E)]
            : [const Color(0xFF0A5D4E), const Color(0xFF07473C)],
      );
}
