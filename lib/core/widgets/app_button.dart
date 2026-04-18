import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

enum AppButtonType { primary, secondary, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.isFullWidth = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isDisabled;
  final dynamic icon;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    VoidCallback? effectiveOnPressed = (isDisabled || isLoading)
        ? null
        : onPressed;

    Widget buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
        ] else if (icon != null) ...[
          FaIcon(icon, size: 20),
          const SizedBox(width: AppSpacing.s8),
        ],
        Text(text),
      ],
    );

    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r16),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
              vertical: AppSpacing.s16,
            ),
            minimumSize: isFullWidth ? const Size(double.infinity, 52) : null,
          ),
          child: buttonContent,
        );
      case AppButtonType.secondary:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            elevation: 0,
            foregroundColor: AppColors.accentBlue,
            side: const BorderSide(color: AppColors.accentBlue, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r16),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
              vertical: AppSpacing.s16,
            ),
            minimumSize: isFullWidth ? const Size(double.infinity, 52) : null,
          ),
          child: _overrideLoadingColor(buttonContent, AppColors.accentBlue),
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accentBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r16),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
          ),
          child: _overrideLoadingColor(buttonContent, AppColors.accentBlue),
        );
    }
  }

  Widget _overrideLoadingColor(Widget content, Color color) {
    if (!isLoading) return content;
    return Theme(
      data: ThemeData(
        progressIndicatorTheme: ProgressIndicatorThemeData(color: color),
      ),
      child: content,
    );
  }
}
