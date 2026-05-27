import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildGothicTheme() {
  const bg = Color(0xFF050505);
  const panel = Color(0xFF0A0A0A);
  const border = Color(0xFF2E2E2E);
  const muted = Color(0xFFA0A0A0);
  const accent = Color(0xFF5A5A5A);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.dark,
    surface: panel,
    onSurfaceVariant: muted,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: bg,
    dividerColor: border,
    cardColor: panel,
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.cinzel(
        color: Colors.white,
        fontSize: 44,
      ),
      bodyMedium: GoogleFonts.ebGaramond(
        color: muted,
        fontSize: 16,
      ),
      labelLarge: GoogleFonts.cinzel(
        color: Colors.white,
        fontSize: 14,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: muted,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: border, width: 1),
      ),
      labelStyle: GoogleFonts.ebGaramond(
        fontSize: 14,
        letterSpacing: 1,
        fontWeight: FontWeight.w600,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: panel,
    ),
  );
}

