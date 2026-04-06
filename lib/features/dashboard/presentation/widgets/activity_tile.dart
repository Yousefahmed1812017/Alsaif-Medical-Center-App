import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// An activity/notification tile similar to the reference design.
class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    this.iconColor,
    this.iconBgColor,
    this.onTap,
  });

  final dynamic icon;
  final String title;
  final String subtitle;
  final String time;
  final Color? iconColor;
  final Color? iconBgColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r12),
          border: Border.all(color: AppColors.border.withAlpha(100)),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconBgColor ?? AppColors.primary50,
                borderRadius: BorderRadius.circular(AppRadius.r12),
              ),
              child: Center(
                child: FaIcon(
                  icon,
                  size: 18,
                  color: iconColor ?? AppColors.primary500,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.headingText,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedText,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s8),

            // Time
            Text(
              time,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedText,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
