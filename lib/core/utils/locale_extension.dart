import 'package:flutter/material.dart';

extension LocaleExtension on BuildContext {
  /// Returns true if the current locale is Arabic.
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';

  /// Returns true if the current reading direction is Right-To-Left.
  bool get isRTL => Directionality.of(this) == TextDirection.rtl;
}
