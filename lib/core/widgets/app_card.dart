import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.s24),
    this.onTap,
    this.radius = AppRadius.r16,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    Widget cardChild = Padding(padding: padding, child: child);

    if (onTap != null) {
      cardChild = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: cardChild,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 6,
            offset: const Offset(0, 4),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: cardChild,
    );
  }
}
