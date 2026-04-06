import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  /// Gets the complete ThemeData for the application based on the language.
  static ThemeData getTheme({required bool isArabic}) {
    final baseTextTheme = isArabic
        ? GoogleFonts.cairoTextTheme()
        : GoogleFonts.poppinsTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary500,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary500,
        onPrimary: AppColors.white,
        secondary: AppColors.primary400,
        onSecondary: AppColors.white,
        error: AppColors.error,
        onError: AppColors.white,
        surface: AppColors.surface,
        onSurface: AppColors.bodyText,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 32,
          height: 40 / 32,
          fontWeight: FontWeight.bold,
          color: AppColors.headingText,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontSize: 28,
          height: 36 / 28,
          fontWeight: FontWeight.bold,
          color: AppColors.headingText,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontSize: 24,
          height: 32 / 24,
          fontWeight: FontWeight.w600,
          color: AppColors.headingText,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 20,
          height: 28 / 20,
          fontWeight: FontWeight.w700,
          color: AppColors.headingText,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontSize: 18,
          height: 26 / 18,
          fontWeight: FontWeight.w700,
          color: AppColors.headingText,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 17,
          height: 24 / 17,
          fontWeight: FontWeight.w600,
          color: AppColors.headingText,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 15,
          height: 22 / 15,
          fontWeight: FontWeight.w600,
          color: AppColors.headingText,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          fontSize: 13,
          height: 20 / 13,
          fontWeight: FontWeight.w600,
          color: AppColors.headingText,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16,
          height: 24 / 16,
          fontWeight: FontWeight.w400,
          color: AppColors.bodyText,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          height: 22 / 14,
          fontWeight: FontWeight.w400,
          color: AppColors.bodyText,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          height: 18 / 12,
          fontWeight: FontWeight.w400,
          color: AppColors.bodyText,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 15,
          height: 20 / 15,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontSize: 11,
          height: 16 / 11,
          fontWeight: FontWeight.w400,
          color: AppColors.mutedText,
        ),
      ),

      // ─── App Bar — clean white, centered ─────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.headingText,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
      ),

      // ─── Cards — white with subtle shadow ────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      // ─── Elevated Button — navy capsule, like reference ──────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary500,
          foregroundColor: AppColors.white,
          textStyle: baseTextTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s32,
            vertical: AppSpacing.s16,
          ),
          minimumSize: const Size(0, 52),
        ),
      ),

      // ─── Outlined Button ─────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: AppColors.primary500,
          side: const BorderSide(color: AppColors.primary500, width: 1.5),
          textStyle: baseTextTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s32,
            vertical: AppSpacing.s16,
          ),
          minimumSize: const Size(0, 52),
        ),
      ),

      // ─── Text Button ─────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
        ),
      ),

      // ─── Input Decoration — outlined fields like the reference ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r12),
          borderSide: const BorderSide(color: AppColors.primary500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.mutedText,
        ),
        labelStyle: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.mutedText,
        ),
        prefixIconColor: AppColors.mutedText,
      ),

      // ─── Divider ─────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: AppSpacing.s24,
      ),

      // ─── Bottom Sheet ────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.r20),
          ),
        ),
      ),

      // ─── Dialog ──────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r20),
        ),
      ),

      // ─── Tab Bar ─────────────────────────────────────────────────
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary500,
        unselectedLabelColor: AppColors.mutedText,
        indicatorColor: AppColors.primary500,
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // ─── Chip ────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        disabledColor: AppColors.border,
        selectedColor: AppColors.primary100,
        secondarySelectedColor: AppColors.primary100,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s8,
        ),
        labelStyle: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.bodyText,
        ),
        secondaryLabelStyle: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.primary600,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r8),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      // ─── FloatingActionButton ────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary500,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }
}
