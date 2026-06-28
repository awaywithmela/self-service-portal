import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF3DBFBF);
  static const Color tealDark = Color(0xFF2A9090);
  static const Color tealLight = Color(0xFF7DD9D9);
  static const Color tealSurface = Color(0xFFEEF8F8);
  static const Color tealMuted = Color(0xFFB2DEDE);
  static const Color darkText = Color(0xFF1A3333);
  static const Color lightText = Color(0xFF5A7D7D);
  static const Color surfaceWhite = Color(0xFFFAFEFE);

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        secondary: tealLight,
        tertiary: tealMuted,
        surface: surfaceWhite,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: tealSurface,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: darkText,
        surfaceTintColor: Colors.transparent,
        shadowColor: darkText.withValues(alpha: 0.08),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 68,
        shape: Border(
          bottom:
              BorderSide(color: tealMuted.withValues(alpha: 0.45), width: 1),
        ),
        iconTheme: const IconThemeData(size: 24, color: tealDark),
        actionsIconTheme: const IconThemeData(size: 24, color: tealDark),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: darkText,
        ),
      ),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
            fontSize: 40, fontWeight: FontWeight.w900, color: darkText),
        displayMedium: GoogleFonts.nunito(
            fontSize: 34, fontWeight: FontWeight.w800, color: darkText),
        headlineSmall: GoogleFonts.nunito(
            fontSize: 26, fontWeight: FontWeight.w800, color: primaryTeal),
        titleLarge: GoogleFonts.nunito(
            fontSize: 22, fontWeight: FontWeight.w700, color: darkText),
        titleMedium: GoogleFonts.nunito(
            fontSize: 18, fontWeight: FontWeight.w600, color: darkText),
        bodyLarge:
            GoogleFonts.nunito(fontSize: 17, color: darkText, height: 1.6),
        bodyMedium:
            GoogleFonts.nunito(fontSize: 15, color: lightText, height: 1.6),
        labelLarge: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: tealMuted, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: tealMuted, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryTeal, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE57373), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE57373), width: 2.5),
        ),
        labelStyle: GoogleFonts.nunito(
            fontSize: 15, fontWeight: FontWeight.w600, color: lightText),
        hintStyle:
            GoogleFonts.nunito(fontSize: 15, color: const Color(0xFFAAC8C8)),
        prefixIconColor: tealLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
          textStyle: GoogleFonts.nunito(
              fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          elevation: 3,
          shadowColor: primaryTeal.withValues(alpha: 0.4),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          side: const BorderSide(color: primaryTeal, width: 2),
          textStyle:
              GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          foregroundColor: primaryTeal,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        shadowColor: primaryTeal.withValues(alpha: 0.08),
      ),
      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(width: 2, color: tealMuted),
        fillColor: WidgetStateProperty.all(primaryTeal),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: tealDark,
        contentTextStyle: GoogleFonts.nunito(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: primaryTeal.withValues(alpha: 0.2),
      ),
    );
  }
}
