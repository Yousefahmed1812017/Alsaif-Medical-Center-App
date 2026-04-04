import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
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
  final IconData? icon;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    VoidCallback? effectiveOnPressed = (isDisabled || isLoading) ? null : onPressed;

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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Simplified color, should match theme based on type
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
        ] else if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.s8),
        ],
        Text(text),
      ],
    );

    // Provide specific styling if needed or rely on ThemeData. We'll rely mostly on ThemeData and tweak slightly for loading.
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: effectiveOnPressed,
          child: buttonContent,
        );
      case AppButtonType.secondary:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          // If loading, change indicator color locally
          child: _overrideLoadingColor(buttonContent, AppColors.primary500),
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          child: _overrideLoadingColor(buttonContent, AppColors.primary500),
        );
    }
  }

  Widget _overrideLoadingColor(Widget content, Color color) {
    if (!isLoading) return content;
    // Replace the CircularProgressIndicator color deep inside
    return Theme(
      data: ThemeData(
        progressIndicatorTheme: ProgressIndicatorThemeData(color: color),
      ),
      child: content,
    );
  }
}
