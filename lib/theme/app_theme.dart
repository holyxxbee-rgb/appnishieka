import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors from Stitch SnapDiary Design
  static const Color primary = Color(0xFF934465);
  static const Color primaryContainer = Color(0xFFE88BAF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF692243);

  static const Color secondary = Color(0xFF9C3B6A);
  static const Color secondaryContainer = Color(0xFFFC89BB);
  static const Color secondaryFixed = Color(0xFFFFD9E5);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryFixed = Color(0xFF3D0023);

  static const Color tertiary = Color(0xFF9F3966);
  static const Color tertiaryContainer = Color(0xFFF980B0);

  static const Color surface = Color(0xFFFFF8F8);
  static const Color background = Color(0xFFFFF8F8);
  static const Color surfaceContainer = Color(0xFFFFE8F1);
  static const Color surfaceContainerLow = Color(0xFFFFF0F4);
  static const Color surfaceContainerHigh = Color(0xFFFFE0ED);
  static const Color surfaceContainerHighest = Color(0xFFFADAE7);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  static const Color onSurface = Color(0xFF28161F);
  static const Color onSurfaceVariant = Color(0xFF524347);
  static const Color outline = Color(0xFF857278);
  static const Color outlineVariant = Color(0xFFD7C1C7);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: Color(0xFF781D4C),
        tertiary: tertiary,
        onTertiary: Colors.white,
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
