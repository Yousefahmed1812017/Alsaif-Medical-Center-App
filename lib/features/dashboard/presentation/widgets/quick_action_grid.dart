import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.bgColor,
  });

  final dynamic icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? AppColors.primary500;
    final tileBg = bgColor ?? tileColor.withAlpha(20);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s12,
          horizontal: AppSpacing.s4,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(4),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tileBg,
                borderRadius: BorderRadius.circular(AppRadius.r16),
              ),
              child: Center(child: FaIcon(icon, size: 20, color: tileColor)),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({
    super.key,
    required this.actions,
    this.crossAxisCount = 4,
  });

  final List<QuickActionTile> actions;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.s12,
      mainAxisSpacing: AppSpacing.s12,
      childAspectRatio: 0.78,
      children: actions,
    );
  }
}

