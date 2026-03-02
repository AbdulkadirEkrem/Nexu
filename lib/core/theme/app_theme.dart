import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    // Create text theme with dark colors for light mode
    final baseTextTheme = GoogleFonts.interTextTheme();
    final darkTextTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(color: AppColors.textPrimary),
      displayMedium: baseTextTheme.displayMedium?.copyWith(color: AppColors.textPrimary),
      displaySmall: baseTextTheme.displaySmall?.copyWith(color: AppColors.textPrimary),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: AppColors.textPrimary),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: AppColors.textPrimary),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: AppColors.textPrimary),
      titleLarge: baseTextTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
      titleMedium: baseTextTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
      titleSmall: baseTextTheme.titleSmall?.copyWith(color: AppColors.textPrimary),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      bodySmall: baseTextTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
      labelLarge: baseTextTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
      labelMedium: baseTextTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
      labelSmall: baseTextTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
    );
    
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      textTheme: darkTextTheme,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.surface,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      cardColor: AppColors.surface,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textHint,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    final darkCardColor = AppColors.surfaceDark; // Lighter navy for cards
    
    // Create text theme with white colors
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    final whiteTextTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(color: Colors.white),
      displayMedium: baseTextTheme.displayMedium?.copyWith(color: Colors.white),
      displaySmall: baseTextTheme.displaySmall?.copyWith(color: Colors.white),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: Colors.white),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: Colors.white),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: Colors.white),
      titleLarge: baseTextTheme.titleLarge?.copyWith(color: Colors.white),
      titleMedium: baseTextTheme.titleMedium?.copyWith(color: Colors.white),
      titleSmall: baseTextTheme.titleSmall?.copyWith(color: Colors.white),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: Colors.white),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: Colors.white70),
      bodySmall: baseTextTheme.bodySmall?.copyWith(color: Colors.white70),
      labelLarge: baseTextTheme.labelLarge?.copyWith(color: Colors.white),
      labelMedium: baseTextTheme.labelMedium?.copyWith(color: Colors.white70),
      labelSmall: baseTextTheme.labelSmall?.copyWith(color: Colors.white70),
    );
    
    return ThemeData.dark().copyWith(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      textTheme: whiteTextTheme,
      colorScheme: ColorScheme.dark(
        primary: AppColors.secondary, // Use Amber as primary in dark mode
        secondary: AppColors.secondary,
        surface: darkCardColor,
        background: AppColors.primary, // Use Navy Blue as background
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.primary, // Corporate Navy background
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: darkCardColor,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      cardColor: darkCardColor,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: Colors.white70,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: GoogleFonts.inter(
          color: Colors.white70,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: const BorderSide(color: AppColors.secondary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

