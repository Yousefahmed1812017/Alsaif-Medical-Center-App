import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

enum AppBadgeType { success, error, warning, info, neutral }

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.text,
    this.type = AppBadgeType.neutral,
  });

  final String text;
  final AppBadgeType type;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case AppBadgeType.success:
        backgroundColor = AppColors.successSoft;
        textColor = AppColors.success;
        break;
      case AppBadgeType.error:
        backgroundColor = AppColors.errorSoft;
        textColor = AppColors.error;
        break;
      case AppBadgeType.warning:
        backgroundColor = AppColors.warningSoft;
        textColor = AppColors.warning;
        break;
      case AppBadgeType.info:
        backgroundColor = AppColors.infoSoft;
        textColor = AppColors.info;
        break;
      case AppBadgeType.neutral:
        backgroundColor = AppColors.surfaceAlt;
        textColor = AppColors.bodyText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.r8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
