import 'package:flutter/material.dart';

/// Design palette inspired by the Dental Clinic reference — deep navy
/// primary with clean whites, soft greys, and medical accent colours.
class AppColors {
  AppColors._();

  // Primary Palette (Deep Navy / Royal Blue)
  static const Color primary50 = Color(0xFFEEF1F8);
  static const Color primary100 = Color(0xFFD5DAF0);
  static const Color primary200 = Color(0xFFACB7E2);
  static const Color primary300 = Color(0xFF7B8FCC);
  static const Color primary400 = Color(0xFF4A64B5);
  static const Color primary500 = Color(0xFF1B2A6B); // ← dominant navy
  static const Color primary600 = Color(0xFF162259);
  static const Color primary700 = Color(0xFF101A47);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF0F3F8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEDF2F7);
  static const Color mutedText = Color(0xFF8E9BAE);
  static const Color bodyText = Color(0xFF3A4356);
  static const Color headingText = Color(0xFF1B2A6B);

  // Semantics
  static const Color success = Color(0xFF22C55E);
  static const Color successSoft = Color(0xFFE8F9EF);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFFF8E1);

  static const Color error = Color(0xFFEF4444);
  static const Color errorSoft = Color(0xFFFEE2E2);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoSoft = Color(0xFFEFF6FF);
}
