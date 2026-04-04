import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.primaryAction,
    this.secondaryAction,
  });

  final Widget title;
  final Widget content;
  final Widget? primaryAction;
  final Widget? secondaryAction;

  /// Helper to easily show the dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget title,
    required Widget content,
    Widget? primaryAction,
    Widget? secondaryAction,
  }) {
    return showDialog<T>(
      context: context,
      builder: (BuildContext context) {
        return AppDialog(
          title: title,
          content: content,
          primaryAction: primaryAction,
          secondaryAction: secondaryAction,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s24,
        vertical: AppSpacing.s16,
      ),
      contentPadding: const EdgeInsets.only(
        left: AppSpacing.s24,
        right: AppSpacing.s24,
        top: AppSpacing.s16,
      ),
      actions: [
        if (secondaryAction != null) secondaryAction!,
        if (primaryAction != null) primaryAction!,
      ],
    );
  }
}
