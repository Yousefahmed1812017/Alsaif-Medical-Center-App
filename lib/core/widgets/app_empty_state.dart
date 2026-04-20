import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = FontAwesomeIcons.folderOpen,
    this.actionText,
    this.onActionPressed,
    /// If true, displays as a centered full-screen state (e.g. list pages).
    /// If false, displays as a compact inline card for dashboard sections.
    this.fullScreen = false,
  });

  final String title;
  final String message;
  final dynamic icon;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final bool fullScreen;

  @override
  Widget build(BuildContext context) {
    if (fullScreen) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s32),
          child: _body(context),
        ),
      );
    }

    // Inline card style for dashboard sections
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 28,
        horizontal: AppSpacing.s24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon bubble
        Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            color: AppColors.primary100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: FaIcon(icon, size: 26, color: AppColors.primary500),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),

        // Title
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),

        // Message
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedText,
              ),
          textAlign: TextAlign.center,
        ),

        // Action
        if (actionText != null && onActionPressed != null) ...[
          const SizedBox(height: AppSpacing.s20),
          TextButton.icon(
            onPressed: onActionPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary500,
              backgroundColor: AppColors.primary100,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s20,
                vertical: AppSpacing.s12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const FaIcon(FontAwesomeIcons.plus, size: 13),
            label: Text(
              actionText!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
