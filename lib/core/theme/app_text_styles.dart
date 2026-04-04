import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  /// Gets the appropriate font family based on locale context
  static TextStyle getFontFamily(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic ? GoogleFonts.cairo() : GoogleFonts.poppins();
  }

  /// Display: 32/40 bold
  static TextStyle display(BuildContext context) => getFontFamily(context).copyWith(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.bold,
        color: AppColors.headingText,
      );

  /// H1: 28/36 bold
  static TextStyle h1(BuildContext context) => getFontFamily(context).copyWith(
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.bold,
        color: AppColors.headingText,
      );

  /// H2: 24/32 semibold
  static TextStyle h2(BuildContext context) => getFontFamily(context).copyWith(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        color: AppColors.headingText,
      );

  /// H3: 20/28 semibold
  static TextStyle h3(BuildContext context) => getFontFamily(context).copyWith(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: AppColors.headingText,
      );

  /// Body Large: 16/24 regular
  static TextStyle bodyLarge(BuildContext context) => getFontFamily(context).copyWith(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: AppColors.bodyText,
      );

  /// Body: 14/22 regular
  static TextStyle body(BuildContext context) => getFontFamily(context).copyWith(
        fontSize: 14,
        height: 22 / 14,
        fontWeight: FontWeight.w400,
        color: AppColors.bodyText,
      );

  /// Body Small: 12/18 regular
  static TextStyle bodySmall(BuildContext context) => getFontFamily(context).copyWith(
        fontSize: 12,
        height: 18 / 12,
        fontWeight: FontWeight.w400,
        color: AppColors.bodyText,
      );

  /// Label: 13/18 semibold
  static TextStyle label(BuildContext context) => getFontFamily(context).copyWith(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w600,
        color: AppColors.bodyText,
      );

  /// Button: 15/20 semibold
  static TextStyle button(BuildContext context) => getFontFamily(context).copyWith(
        fontSize: 15,
        height: 20 / 15,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  /// Caption: 11/16 regular
  static TextStyle caption(BuildContext context) => getFontFamily(context).copyWith(
        fontSize: 11,
        height: 16 / 11,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedText,
      );
}
