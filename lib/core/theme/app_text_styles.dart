import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle getFontFamily(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic ? GoogleFonts.cairo() : GoogleFonts.poppins();
  }

  static TextStyle display(BuildContext context) =>
      getFontFamily(context).copyWith(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle h1(BuildContext context) => getFontFamily(context).copyWith(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle h2(BuildContext context) => getFontFamily(context).copyWith(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle h3(BuildContext context) => getFontFamily(context).copyWith(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyLarge(BuildContext context) =>
      getFontFamily(context).copyWith(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: AppColors.bodyText,
      );

  static TextStyle body(BuildContext context) =>
      getFontFamily(context).copyWith(
        fontSize: 14,
        height: 22 / 14,
        fontWeight: FontWeight.w400,
        color: AppColors.bodyText,
      );

  static TextStyle bodySmall(BuildContext context) =>
      getFontFamily(context).copyWith(
        fontSize: 12,
        height: 18 / 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle label(BuildContext context) =>
      getFontFamily(context).copyWith(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w600,
        color: AppColors.bodyText,
      );

  static TextStyle button(BuildContext context) =>
      getFontFamily(context).copyWith(
        fontSize: 16,
        height: 20 / 16,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  static TextStyle caption(BuildContext context) =>
      getFontFamily(context).copyWith(
        fontSize: 11,
        height: 16 / 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );
}
